defmodule Notification.Notification do
  use TypedStruct

  alias Notification.Notification

  def jason(), do: [except: [:keep?, :db_id]]

  typedstruct enforce: true do
    field(:type, :sound | :text | :box)
    field(:key, atom())
    field(:keep?, boolean())
    field(:system_id, number() | nil)
    field(:data, map() | nil)
    field(:db_id, number() | nil)
  end

  def new(type, key, keep?, system_id, data, db_id) do
    %Notification{
      type: type,
      key: key,
      keep?: keep?,
      system_id: system_id,
      data: data,
      db_id: db_id
    }
  end
end
