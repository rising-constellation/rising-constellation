defmodule Instance.Character.Spy do
  use TypedStruct

  alias Instance.Character

  @initial_cover 80
  @min_cover 0
  @max_cover 100
  @cover_recovery 0.25

  def jason(), do: []

  typedstruct enforce: true do
    field(:cover, %Core.DynamicValue{}, default: Core.DynamicValue.new(@initial_cover))
    field(:infiltrate_coef, %Core.Value{}, default: Core.Value.new())
    field(:sabotage_coef, %Core.Value{}, default: Core.Value.new())
    field(:assassination_coef, %Core.Value{}, default: Core.Value.new())
  end

  def new() do
    %Character.Spy{}
  end

  def undercover?(cover, instance_id) do
    c = Data.Querier.one(Data.Game.Constant, instance_id, :main)
    cover >= c.cover_threshold
  end

  def discovered?(cover, instance_id) do
    c = Data.Querier.one(Data.Game.Constant, instance_id, :main)
    cover < c.cover_threshold
  end

  def lose_cover(%Character.Spy{} = state, instance_id, amount) do
    new_cover =
      state.cover
      |> Core.DynamicValue.remove_value(amount)
      |> Core.DynamicValue.clamp_value(@min_cover, @max_cover)

    became_discovered? = undercover?(state.cover.value, instance_id) and discovered?(new_cover.value, instance_id)
    {%{state | cover: new_cover}, became_discovered?}
  end

  def increase_cover(%Character.Spy{} = state, _, _) when state.cover.value == @max_cover do
    {state, false}
  end

  def increase_cover(%Character.Spy{} = state, instance_id, elapsed_time) do
    new_cover =
      state.cover
      |> Core.DynamicValue.next_tick(elapsed_time)
      |> Core.DynamicValue.clamp_value(@min_cover, @max_cover)

    became_discovered? = discovered?(state.cover.value, instance_id) and undercover?(new_cover.value, instance_id)
    {%{state | cover: new_cover}, became_discovered?}
  end

  def compute_bonus(%Character.Spy{} = state, instance_id, bonuses) do
    # initial state
    cover =
      Core.DynamicValue.new(state.cover.value)
      |> Core.DynamicValue.add(:misc, Core.ValuePart.new(:default, @cover_recovery))

    state = %{
      state
      | cover: cover,
        infiltrate_coef: Core.Value.new(),
        sabotage_coef: Core.Value.new(),
        assassination_coef: Core.Value.new()
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
      |> Enum.filter(fn bonus_data -> bonus_data.to.to == :spy end)

    state = Core.Bonus.apply_bonuses(state, :spy, bonuses)

    if discovered?(state.cover.value, instance_id) do
      malus =
        [:spy_infiltrate, :spy_sabotage, :spy_assassination]
        |> Enum.map(fn key ->
          %{reason: {:misc, :discovered}, bonus: %Core.Bonus{from: key, value: -1, type: :mul, to: key}}
        end)
        |> Enum.map(fn data ->
          %{
            reason: data.reason,
            bonus: data.bonus,
            from: Data.Querier.one(Data.Game.BonusPipelineIn, instance_id, data.bonus.from),
            to: Data.Querier.one(Data.Game.BonusPipelineOut, instance_id, data.bonus.to)
          }
        end)

      Core.Bonus.apply_bonuses(state, :spy, malus)
    else
      state
    end
  end
end
