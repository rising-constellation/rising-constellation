defmodule Notification.Text do
  alias Notification.Notification

  # list of valid text notification
  # %{key: {:keep?, :require_system?, :data_fields}}
  # :key -> notification key
  # :keep? -> the notification will be stored until player comes back
  # :require_system? -> the notification require that system_id != nil
  # :data_fields -> list of required fields in the map "data"
  @list %{
    receive_resources: {true, false, [:player, :resources]},
    start_uprising: {true, true, [:system]},
    character_lvlup: {false, true, [:character, :level]},
    system_under_siege: {false, true, [:system]},
    interception_and_flight: {true, true, [:admiral, :system]},
    colonization_started: {false, true, [:admiral, :system]},
    colonization_cancelled: {true, true, [:admiral, :system]},
    loot_started: {false, true, [:admiral, :system]},
    loot_cancelled: {true, true, [:admiral, :system]},
    raid_started: {false, true, [:admiral, :system]},
    raid_cancelled: {true, true, [:admiral, :system]},
    conquest_started: {false, true, [:admiral, :system]},
    conquest_cancelled: {true, true, [:admiral, :system]},
    foreign_spy_discovered: {true, true, [:spy, :system]},
    infiltration_started: {false, true, [:spy, :system]},
    infiltration_cancelled: {true, true, [:spy, :system]},
    make_dominion_started: {false, true, [:speaker, :system]},
    make_dominion_cancelled: {true, true, [:speaker, :system]},
    encourage_hate_started: {false, true, [:speaker, :system]},
    encourage_hate_cancelled: {true, true, [:speaker, :system]},
    foreign_agent_stopped: {false, true, [:type, :player, :system]},
    foreign_agent_passed: {false, true, [:type, :player, :system]},
    offer_sold: {true, false, [:buyer, :offer_id]}
  }

  def new(key, system_id \\ nil, data \\ nil) do
    case Map.get(@list, key) do
      {keep?, require_system?, data_fields} ->
        if require_system? and system_id == nil, do: throw(:system_id_required)

        Enum.each(data_fields, fn field ->
          unless Map.has_key?(data, field), do: throw(:missing_data_field)
        end)

        Notification.new(:text, key, keep?, system_id, data, nil)

      nil ->
        throw(:text_notification_not_found)
    end
  end
end
