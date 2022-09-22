defmodule Instance.Faction.ChatMessage do
  use TypedStruct
  use Util.MakeEnumerable

  alias Instance.Faction

  def jason(), do: []

  typedstruct enforce: true do
    field(:from, String.t())
    field(:timestamp, integer())
    field(:message, String.t())
  end

  def new(from, message) do
    %Faction.ChatMessage{
      from: from,
      timestamp: :os.system_time(:seconds),
      message: String.slice(message, 0..1_000)
    }
  end
end
