defmodule Notification.Character do
  def convert(character, visibility \\ 5) do
    Instance.Faction.Character.obfuscate(character, visibility)
  end

  def diff(previous, current, visibility \\ 5) do
    %{
      previous: Notification.Character.convert(previous, visibility),
      current: Notification.Character.convert(current, visibility)
    }
  end
end
