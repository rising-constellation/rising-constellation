defmodule Data.Game.CharacterRank.Content do
  def data do
    [
      %Data.Game.CharacterRank{
        key: :common,
        id: 1,
        size: 2,
        initial_experience_range: 11..23,
        initial_protection_range: 0..0,
        initial_determination_range: 0..0,
        initial_skill_points_range: 0..0,
        cost_factor: 2,
        nth_factor: 0.01
      },
      %Data.Game.CharacterRank{
        key: :remarkable,
        id: 2,
        size: 3,
        initial_experience_range: 76..118,
        initial_protection_range: 0..10,
        initial_determination_range: 0..10,
        initial_skill_points_range: 0..2,
        cost_factor: 21,
        nth_factor: 0.05
      },
      %Data.Game.CharacterRank{
        key: :exceptional,
        id: 3,
        size: 3,
        initial_experience_range: 160..250,
        initial_protection_range: 5..20,
        initial_determination_range: 5..20,
        initial_skill_points_range: 2..6,
        cost_factor: 36,
        nth_factor: 0.25
      }
    ]
  end
end
