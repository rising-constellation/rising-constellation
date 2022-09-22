defmodule Portal.PressKitLive do
  use Portal, :live_view

  @impl true
  def mount(_params, _session, socket),
    do: {:ok, assign(socket, language: :en)}

  @impl true
  def handle_event("set_fr", _value, socket),
    do: {:noreply, assign(socket, language: :fr)}

  @impl true
  def handle_event("set_en", _value, socket),
    do: {:noreply, assign(socket, language: :en)}
end
