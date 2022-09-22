defmodule Instance.Character.Speaker do
  use TypedStruct

  alias Instance.Character

  def jason(), do: []

  typedstruct enforce: true do
    field(:cooldown, %Core.CooldownValue{}, default: Core.CooldownValue.new())
    field(:make_dominion_coef, %Core.Value{}, default: Core.Value.new())
    field(:encourage_hate_coef, %Core.Value{}, default: Core.Value.new())
    field(:conversion_coef, %Core.Value{}, default: Core.Value.new())
  end

  def new() do
    %Character.Speaker{}
  end

  def set_cooldown(%Character.Speaker{} = state, duration) do
    %{state | cooldown: Core.CooldownValue.set(state.cooldown, duration)}
  end

  def update_cooldown(%Character.Speaker{} = state, elapsed_time) do
    new_cooldown = Core.CooldownValue.next_tick(state.cooldown, elapsed_time)
    has_changed = Core.CooldownValue.locked?(state.cooldown) and not Core.CooldownValue.locked?(new_cooldown)

    {%{state | cooldown: new_cooldown}, has_changed}
  end

  def locked?(%Character.Speaker{} = state) do
    Core.CooldownValue.locked?(state.cooldown)
  end

  def compute_bonus(%Character.Speaker{} = state, instance_id, bonuses) do
    state = %{
      state
      | make_dominion_coef: Core.Value.new(),
        encourage_hate_coef: Core.Value.new(),
        conversion_coef: Core.Value.new()
    }

    bonuses =
      Enum.map(bonuses, fn data ->
        %{
          reason: data.reason,
          bonus: data.bonus,
          from: Data.Querier.one(Data.Game.BonusPipelineIn, instance_id, data.bonus.from),
          to: Data.Querier.one(Data.Game.BonusPipelineOut, instance_id, data.bonus.to)
        }
      end)
      |> Enum.filter(fn bonus_data -> bonus_data.to.to == :speaker end)

    Core.Bonus.apply_bonuses(state, :speaker, bonuses)
  end
end
