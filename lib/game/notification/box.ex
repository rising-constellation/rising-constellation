defmodule Notification.Box do
  alias Notification.Notification

  # list of valid box notification
  # %{key: :data_fields}
  # :key -> notification key
  # :data_fields -> list of required fields in the map "data"
  @list %{
    colonization: [:system, :admiral],
    fight: [:system, :scale, :report_id, :outcome, :admirals],
    loot: [:system, :side, :balance_of_power, :siege_logs, :loot, :outcome, :admiral],
    raid: [:system, :side, :balance_of_power, :siege_logs, :outcome, :admiral],
    conquest: [:system, :side, :balance_of_power, :siege_logs, :outcome, :admiral],
    infiltration: [:system, :side, :balance_of_power, :contact_count, :outcome, :spy],
    assassination: [:system, :side, :balance_of_power, :outcome, :spy, :target],
    sabotage: [:system, :side, :balance_of_power, :outcome, :spy, :target],
    make_dominion: [:system, :side, :balance_of_power, :outcome, :speaker],
    encourage_hate: [:system, :side, :balance_of_power, :outcome, :system_penalty, :speaker],
    conversion: [:system, :side, :balance_of_power, :outcome, :speaker, :target]
  }

  def new(key, system_id, data) do
    case Map.get(@list, key) do
      nil ->
        throw(:box_notification_not_found)

      data_fields ->
        if system_id == nil, do: throw(:system_id_required)

        Enum.each(data_fields, fn field ->
          unless Map.has_key?(data, field), do: throw(:missing_data_field)
        end)

        Notification.new(:box, key, true, system_id, data, nil)
    end
  end
end
