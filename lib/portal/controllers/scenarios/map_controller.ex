defmodule Portal.MapController do
  @moduledoc """
  The Map controller.

  Thumbnail files URI: `https://waffle-uploads.s3.fr-par.scw.cloud/storage/thumbnails/scenarios/id/filename_thumb.png`

  ### Logged in as admin:

  Create a Map:
      POST /maps
  Update a Map:
      PUT /maps/:mid
  Delete a Map
      DELETE /maps/:mid

  ### Logged in as regular user:

  List the Maps:
      GET /maps, (optional) body: %{filters: %{size: ..., speed: ...}}
  Get a single Map:
      GET /maps/:mid
  """
  use Portal, :controller

  alias RC.Scenarios

  require Logger

  action_fallback(Portal.FallbackController)

  def index(conn, params) do
    maps = Scenarios.list_maps(params)

    conn
    |> Scrivener.Headers.paginate(maps)
    |> render("index.json", maps: maps)
  end

  def create(conn, %{"map" => map_params}) do
    created_map =
      if Map.has_key?(map_params, "thumbnail") do
        {:ok, %{map_with_thumbnail: map}} = Scenarios.create_map(map_params)
        {:ok, map}
      else
        Scenarios.create_map(map_params, :no_thumbnail)
      end

    case created_map do
      {:ok, map} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", Routes.map_path(conn, :show, map))
        |> render("show.json", map: map)

      error ->
        error
    end
  end

  def preview_edges(conn, %{"systems" => systems, "blackholes" => blackholes}) do
    systems =
      Enum.map(systems, fn %{"key" => key, "position" => %{"x" => x, "y" => y}} ->
        %{id: key, position: %Spatial.Position{x: x, y: y}}
      end)

    blackholes =
      Enum.map(blackholes, fn %{"radius" => radius, "position" => %{"x" => x, "y" => y}} ->
        %{radius: radius, position: %Spatial.Position{x: x, y: y}}
      end)

    edges = Instance.Galaxy.SpatialGraph.generate_edges(systems, blackholes)

    conn
    |> put_status(200)
    |> render("edges.json", edges: edges)
  end

  def show(conn, %{"mid" => id}) do
    case Scenarios.get_map(id) do
      nil ->
        {:error, :not_found}

      map ->
        render(conn, "show.json", map: map)
    end
  end

  def update(conn, %{"mid" => id, "map" => map_params}) do
    with map when not is_nil(map) <- Scenarios.get_map(id),
         {:ok, %RC.Scenarios.Map{} = map} <- Scenarios.update_map(map, map_params) do
      render(conn, "show.json", map: map)
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  def delete(conn, %{"mid" => id}) do
    with map when not is_nil(map) <- Scenarios.get_map_as_scenario(id),
         {:ok, _} <- Scenarios.delete_scenario(map) do
      send_resp(conn, :no_content, "")
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end
end
