defmodule Instance.Faction.StellarSystem do
  use TypedStruct
  use Util.MakeEnumerable

  alias Instance.Faction
  alias Spatial.Position
  alias Instance.StellarSystem
  alias Instance.StellarSystem.Tile
  alias Instance.StellarSystem.Character
  alias Instance.Character.Spy

  def jason(), do: []

  typedstruct enforce: false do
    field(:id, integer())
    field(:position, %Position{})
    field(:sector_id, integer())
    field(:name, String.t())
    field(:type, atom())
    field(:status, atom())
    field(:owner, %StellarSystem.Player{})
    field(:governor, %StellarSystem.Character{} | nil)
    field(:characters, [%StellarSystem.Character{}])
    field(:bodies, [%StellarSystem.StellarBody{}])
    field(:queue, %StellarSystem.ProductionQueue{})
    field(:population, %Core.DynamicValue{})
    field(:workforce, integer())
    field(:used_workforce, integer())
    field(:population_status, atom())
    field(:population_class, atom() | nil)
    field(:habitation, %Core.Value{})
    field(:production, %Core.Value{})
    field(:technology, %Core.Value{})
    field(:ideology, %Core.Value{})
    field(:credit, %Core.Value{})
    field(:happiness, %Core.Value{})
    field(:mobility, %Core.Value{})
    field(:counter_intelligence, %Core.Value{})
    field(:defense, %Core.Value{})
    field(:remove_contact, %Core.Value{})
    field(:radar, %Core.Value{})
    field(:fighter_lvl, %Core.Value{})
    field(:corvette_lvl, %Core.Value{})
    field(:frigate_lvl, %Core.Value{})
    field(:capital_lvl, %Core.Value{})
    field(:siege, atom() | nil)
    field(:contact, %Core.Value{})
  end

  def obfuscate(system, contact, faction_id, instance_id) do
    visibility_level = contact.value
    new_system = %Faction.StellarSystem{contact: contact}

    fields_levels = %{
      0 => [:id, :position, :sector_id, :name, :type, :status, :owner],
      1 => [],
      2 => [:governor, :characters, :defense, :siege],
      3 => [:population, :workforce, :used_workforce, :habitation, :happiness, :population_status, :population_class],
      4 => [:production, :technology, :ideology, :credit, :counter_intelligence],
      5 => [
        :queue,
        :radar,
        :remove_contact,
        :mobility,
        :fighter_lvl,
        :corvette_lvl,
        :frigate_lvl,
        :capital_lvl
      ]
    }

    # show bodies list over 0 visibility
    new_system =
      if visibility_level > 0,
        do: Map.put(new_system, :bodies, Map.get(system, :bodies)),
        else: Map.put(new_system, :bodies, [])

    # apply fields_levels filter on fields
    new_system =
      Enum.reduce(fields_levels, new_system, fn {level, fields}, s1 ->
        if level <= visibility_level do
          Enum.reduce(fields, s1, fn field, s2 ->
            Map.put(s2, field, Map.get(system, field))
          end)
        else
          s1
        end
      end)

    # show resources details with visibility of 5
    new_system =
      Enum.reduce(new_system, new_system, fn {key, value}, acc ->
        if key != :contact and Enum.member?([:advanced, :dynamic], Util.Type.typeof_value(value)) and
             visibility_level < 5,
           do: Map.put(acc, key, Map.put(value, :details, [])),
           else: acc
      end)

    Enum.reduce(new_system, new_system, fn {key, value}, acc ->
      # filter infos in bodies
      acc =
        if key == :bodies,
          do: Map.put(acc, key, obfuscate_bodies(value, visibility_level)),
          else: acc

      # filter governor
      acc =
        if key == :governor and new_system.governor != nil,
          do: Map.put(acc, key, Character.obfuscate(value, visibility_level)),
          else: acc

      # filter characters
      if key == :characters and is_list(value) do
        value =
          Enum.map(value, fn c ->
            # remove undercover spies
            if c.type == :spy and c.owner.faction_id != faction_id and Spy.undercover?(c.cover, instance_id),
              do: nil,
              else: Character.obfuscate(c, visibility_level)
          end)

        Map.put(acc, key, Enum.filter(value, fn c -> c != nil end))
      else
        acc
      end
    end)
  end

  defp obfuscate_bodies(bodies, visibility_level) when is_list(bodies) do
    Enum.map(bodies, fn body ->
      Enum.reduce(body, body, fn {key, value}, b ->
        case key do
          :tiles ->
            Map.put(b, :tiles, obfuscate_tiles(value, visibility_level))

          :bodies ->
            Map.put(b, :bodies, obfuscate_bodies(value, visibility_level))

          key ->
            value =
              cond do
                key == :population and visibility_level <= 2 -> :hidden
                key == :industrial_factor and visibility_level == 0 -> :hidden
                key == :technological_factor and visibility_level == 0 -> :hidden
                key == :activity_factor and visibility_level == 0 -> :hidden
                true -> value
              end

            Map.put(b, key, value)
        end
      end)
    end)
  end

  defp obfuscate_bodies(bodies, _visibility_level), do: bodies

  defp obfuscate_tiles(_tiles, 0), do: []

  defp obfuscate_tiles(tiles, visibility_level),
    do: Enum.map(tiles, fn tile -> Tile.obfuscate(tile, visibility_level) end)
end
