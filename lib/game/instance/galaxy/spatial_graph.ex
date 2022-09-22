defmodule Instance.Galaxy.SpatialGraph do
  alias Spatial.Position

  @max_dist 12
  @max_dist_squared @max_dist * @max_dist

  defp distance(system_1, system_2) do
    Position.distance(system_1.position, system_2.position)
  end

  defp dist_squared(system_1, system_2) do
    Position.dist_squared(system_1.position, system_2.position)
  end

  def generate_edges(systems, blackholes) do
    travel_graph = Graph.new(type: :undirected)
    systems_by_id = Enum.reduce(systems, %{}, fn sys, acc -> Map.put(acc, sys.id, sys) end)
    travel_graph = Enum.reduce(systems, travel_graph, fn system, acc -> Graph.add_vertex(acc, system.id) end)

    travel_graph =
      Enum.reduce(systems, travel_graph, fn system, acc ->
        # since sqrt(x) < sqrt(y) <=> x < y we can avoid an expensive sqrt(x) in multiple loop

        # get blackholes that could interfer with current systems edges
        near_blackholes =
          Enum.filter(blackholes, fn b ->
            Position.dist_squared(b.position, system.position) < :math.pow(@max_dist + b.radius, 2)
          end)

        neighbors =
          systems
          |> Enum.filter(fn s -> dist_squared(system, s) < @max_dist_squared and s.id != system.id end)
          |> Enum.filter(fn s -> not edge_traverse_a_blackhole?(s, system, near_blackholes) end)

        Enum.reduce(neighbors, acc, fn n, acc2 ->
          Graph.add_edge(acc2, system.id, n.id, weight: distance(system, n))
        end)
      end)

    travel_graph = assemble_graph_components(travel_graph, systems, systems_by_id, blackholes)

    Graph.edges(travel_graph)
    |> Enum.map(fn edge ->
      %{
        s1: systems_by_id[edge.v1],
        s2: systems_by_id[edge.v2],
        weight: edge.weight
      }
    end)
  end

  defp assemble_graph_components(graph, systems, systems_by_id, blackholes) do
    if length(Graph.components(graph)) == 1 do
      graph
    else
      graph =
        Enum.reduce(Graph.components(graph), graph, fn component, acc1 ->
          nearest_couples =
            Task.async_stream(component, fn system_id ->
              system = systems_by_id[system_id]

              nearest_neighbor =
                Enum.min_by(systems, fn s ->
                  if s.id == system.id or Enum.member?(component, s.id),
                    do: :infinity,
                    else: distance(system, s)
                end)

              distance = distance(system, nearest_neighbor)

              {system, nearest_neighbor, distance}
            end)
            |> Stream.map(fn {:ok, result} -> result end)
            |> Enum.to_list()

          nearest_couples_sorted = Enum.sort(nearest_couples, fn {_, _, d1}, {_, _, d2} -> d1 <= d2 end)

          nearest_couple =
            Enum.reduce(nearest_couples_sorted, nil, fn {origin, target, distance}, acc ->
              if is_nil(acc) and not edge_traverse_a_blackhole?(origin, target, blackholes) do
                {origin, target, distance}
              else
                acc
              end
            end)

          {origin, target, distance} =
            case nearest_couple do
              nil -> hd(nearest_couples_sorted)
              nearest_couple -> nearest_couple
            end

          Graph.add_edge(acc1, origin.id, target.id, weight: distance)
        end)

      assemble_graph_components(graph, systems, systems_by_id, blackholes)
    end
  end

  # Find out if the edge between sys1 and sys2 traverse the given disk (blackhole)
  # adapted from there : https://stackoverflow.com/a/1084899
  # probably not the best solution
  # maybe dig from there http://paulbourke.net/geometry/pointlineplane/
  defp edge_traverse_a_blackhole?(sys1, sys2, blackholes) do
    p1 = sys1.position
    p2 = sys2.position
    p1p2 = Position.substr(p2, p1)
    norm = Position.dot(p1p2, p1p2)

    Enum.any?(blackholes, fn b ->
      p3 = b.position
      p1p3 = Position.substr(p1, p3)
      d1 = 2 * Position.dot(p1p3, p1p2)
      d2 = Position.dot(p1p3, p1p3) - b.radius * b.radius
      discriminant = d1 * d1 - 4 * norm * d2

      if discriminant < 0 do
        false
      else
        discriminant = :math.sqrt(discriminant)
        t1 = (-d1 - discriminant) / (2 * norm)
        t2 = (-d1 + discriminant) / (2 * norm)

        cond do
          t1 >= 0 && t1 <= 1 -> true
          t2 >= 0 && t2 <= 1 -> true
          true -> false
        end
      end
    end)
  end
end
