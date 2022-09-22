defmodule Instance do
  @moduledoc """
  An instance is a supervision tree containing three process types:
  1. an Instance Supervisor, a dynamic supervisor
  2. an Instance Manager, a GenServer used to interact with the instance (create it, start it, stop it, snapshot it, etc)
  3. a bunch 'agent processes', ie. TickServers (specialized GenServers) representing Characters, Factions, StellarSystems, etc
  """
end
