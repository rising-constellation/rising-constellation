defmodule RC.PlayerEvents do
  import Ecto.Query, warn: false

  alias RC.Repo
  alias RC.Instances.PlayerEvent

  def create(attrs \\ %{}) do
    %PlayerEvent{}
    |> PlayerEvent.changeset(attrs)
    |> Repo.insert()
  end

  def get_for_player(assigns, params \\ %{}) do
    from(e in PlayerEvent,
      where:
        e.instance_id == ^assigns.instance_id and
          (e.registration_id == ^assigns.registration_id or
             e.faction_id == ^assigns.faction_id or
             (is_nil(e.faction_id) and is_nil(e.registration_id))),
      order_by: [desc: :inserted_at]
    )
    |> RC.Repo.paginate(params)
  end
end
