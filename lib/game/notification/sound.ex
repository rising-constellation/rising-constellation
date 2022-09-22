defmodule Notification.Sound do
  alias Notification.Notification

  # list of valid sound notification
  @list [
    :new_object_in_radar,
    :ship_finished,
    :building_finished
  ]

  def new(key) do
    if key not in @list do
      throw(:sound_notification_not_found)
    end

    Notification.new(:sound, key, false, nil, nil, nil)
  end
end
