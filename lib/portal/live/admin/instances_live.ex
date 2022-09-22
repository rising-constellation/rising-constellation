defmodule Portal.InstancesLive do
  use Portal, :admin_live_view

  alias RC.Instances

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, %{filters: Instances.Instance, show_filters: false})}
  end

  @impl true
  def handle_params(params, _, socket) do
    params = Map.put(%{}, "page", Map.get(params, "page", nil))
    assigns = get_and_assign_page(params)

    instances_to_fix =
      RC.Instances.update_instances_state_if_needed()
      |> Enum.map(fn %{id: id} -> id end)

    assigns = Keyword.merge(assigns, instances_to_fix: instances_to_fix)
    {:noreply, assign(socket, assigns)}
  end

  def handle_event("filter", %{"Elixir.RC.Instances.Instance" => filters} = params, socket) do
    params = Map.put(%{}, "page", Map.get(params, "page", nil))

    filters =
      Enum.reduce(filters, %{}, fn {key, val}, acc ->
        case val do
          "" -> acc
          val -> Map.put(acc, key, val)
        end
      end)

    assigns = Map.merge(params, filters) |> get_and_assign_page()
    {:noreply, assign(socket, assigns)}
  end

  @impl true
  def handle_event("fix_instances", _params, socket) do
    RC.Instances.update_instances_state_if_needed(true)
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_filters", _params, socket) do
    {:noreply, assign(socket, show_filters: !socket.assigns.show_filters)}
  end

  defp get_and_assign_page(params) do
    %{
      entries: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    } =
      case Instances.list_instances_admin(params) do
        {:ok, result} ->
          result

        _result ->
          %{
            entries: [],
            page_number: 0,
            page_size: 0,
            total_entries: 0,
            total_pages: 0
          }
      end

    [
      instances: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    ]
  end
end
