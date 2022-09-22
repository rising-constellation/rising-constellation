defmodule RC.Store do
  import Ecto.Query, warn: false

  alias RC.Repo
  alias RC.Store.StoreInventory

  def list_steam_keys(status, params \\ %{}) do
    available_unit = if status == :available, do: 1, else: 0

    from(item in StoreInventory,
      where: item.available_units == ^available_unit,
      where: item.type == "steam_key",
      order_by: [desc: :id]
    )
    |> RC.Repo.paginate(params)
  end

  def add_steam_key(key) do
    %StoreInventory{}
    |> StoreInventory.changeset(%{
      item: key,
      type: "steam_key",
      available_units: 1,
      is_hidden: "false"
    })
    |> Repo.insert()
  end
end
