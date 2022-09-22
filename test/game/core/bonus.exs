defmodule Core.BonusTest do
  use ExUnit.Case, async: true

  def credit_percent(percent) do
    bonus = %Core.Bonus{from: :player_credit, to: :player_credit, type: :mul, value: percent / 100}

    from = %Data.Game.BonusPipelineIn{
      from: :player,
      from_key: :credit,
      icon: "credit",
      key: :player_credit,
      order: 10
    }

    reason = {:doctrine, :credit_perc_1}

    to = %Data.Game.BonusPipelineOut{
      icon: "credit",
      key: :player_credit,
      to: :player,
      to_key: :credit
    }

    %{reason: reason, bonus: bonus, to: to, from: from}
  end

  def credit_add(val) do
    bonus = %Core.Bonus{from: :direct, to: :player_credit, type: :add, value: val}

    from = %Data.Game.BonusPipelineIn{
      from: :none,
      from_key: nil,
      icon: nil,
      key: :direct,
      order: 10
    }

    reason = {:doctrine, String.to_atom("credit_add_#{val}")}

    to = %Data.Game.BonusPipelineOut{
      icon: "credit",
      key: :player_credit,
      to: :player,
      to_key: :credit
    }

    %{reason: reason, bonus: bonus, to: to, from: from}
  end

  test "multiplicative bonuses apply to positive values" do
    state = %{
      credit: %Core.DynamicValue{
        change: 100,
        details: %{system: [%Core.ValuePart{reason: "Haus", value: 100}]},
        value: 5_000
      }
    }

    bonuses = [credit_percent(50)]

    assert %Core.DynamicValue{
             change: 150.0,
             details: %{
               doctrine: [%Core.ValuePart{reason: :credit_perc_1, value: 50.0}],
               system: [%Core.ValuePart{reason: "Haus", value: 100}]
             },
             value: 5_000
           } == Core.Bonus.apply_bonuses(state, :player, bonuses).credit
  end

  test "multiplicative bonuses do not apply to negative values" do
    state = %{
      credit: %Core.DynamicValue{
        change: 100,
        details: %{system: [%Core.ValuePart{reason: "Haus", value: 100}]},
        value: -5_000
      }
    }

    bonuses = [credit_percent(50)]

    assert %Core.DynamicValue{
             change: 100,
             details: %{
               doctrine: [%Core.ValuePart{reason: :credit_perc_1, value: 0}],
               system: [%Core.ValuePart{reason: "Haus", value: 100}]
             },
             value: -5_000
           } == Core.Bonus.apply_bonuses(state, :player, bonuses).credit
  end

  test "additive bonuses cumulate properly" do
    state = %{
      credit: %Core.DynamicValue{
        change: 100,
        details: %{system: [%Core.ValuePart{reason: "Haus", value: 100}]},
        value: 0
      }
    }

    bonuses = [credit_add(50), credit_add(25)]

    assert %Core.DynamicValue{
             change: 175,
             details: %{
               doctrine: [
                 %Core.ValuePart{reason: :credit_add_25, value: 25},
                 %Core.ValuePart{reason: :credit_add_50, value: 50}
               ],
               system: [%Core.ValuePart{reason: "Haus", value: 100}]
             },
             value: 0
           } == Core.Bonus.apply_bonuses(state, :player, bonuses).credit
  end

  test "multiplicative bonuses apply to last additive state" do
    value = 100

    state = %{
      credit: %Core.DynamicValue{
        change: 100,
        details: %{system: [%Core.ValuePart{reason: "Haus", value: value}]},
        value: 0
      }
    }

    expected_value = value + 50 + 50 + (value + 50 + 50) * 0.5

    expected = %Core.DynamicValue{
      change: expected_value,
      details: %{
        doctrine: [
          %Core.ValuePart{reason: :credit_add_50, value: 50},
          %Core.ValuePart{reason: :credit_add_50, value: 50},
          # 100.0 because (value + 50 + 50) == 200, 50% of 200 == 100
          %Core.ValuePart{reason: :credit_perc_1, value: 100.0}
        ],
        system: [%Core.ValuePart{reason: "Haus", value: 100}]
      },
      value: 0
    }

    bonuses = [credit_percent(50), credit_add(50), credit_add(50)]
    assert expected == Core.Bonus.apply_bonuses(state, :player, bonuses).credit

    bonuses = [credit_add(50), credit_percent(50), credit_add(50)]
    assert expected == Core.Bonus.apply_bonuses(state, :player, bonuses).credit

    bonuses = [credit_add(50), credit_add(50), credit_percent(50)]
    assert expected == Core.Bonus.apply_bonuses(state, :player, bonuses).credit
  end

  test "multiplicative bonuses apply to base state" do
    value = 100

    state = %{
      credit: %Core.DynamicValue{
        change: 100,
        details: %{system: [%Core.ValuePart{reason: "Haus", value: value}]},
        value: 0
      }
    }

    expected_value = value + value * 0.15

    expected = %Core.DynamicValue{
      change: expected_value,
      details: %{
        doctrine: [
          %Core.ValuePart{reason: :credit_perc_1, value: 10.0},
          %Core.ValuePart{reason: :credit_perc_1, value: 5.0}
        ],
        system: [%Core.ValuePart{reason: "Haus", value: 100}]
      },
      value: 0
    }

    bonuses = [credit_percent(5), credit_percent(10)]
    assert expected == Core.Bonus.apply_bonuses(state, :player, bonuses).credit

    # percents should add up: -5% -5% = -10%
    # so:  100 -5% -5% = 100 -10% = 90
    # NOT: (100 -5%) = 95 -> 95 -5% = 90.25
    [
      [credit_percent(10), credit_percent(5)],
      [credit_percent(5), credit_percent(5), credit_percent(5)],
      [credit_percent(5), credit_percent(5), credit_percent(1), credit_percent(4)]
    ]
    |> Enum.each(fn bonuses ->
      assert 115.0 == Core.Bonus.apply_bonuses(state, :player, bonuses).credit.change
    end)
  end
end
