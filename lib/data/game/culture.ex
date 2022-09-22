defmodule Data.Game.Culture do
  use TypedStruct
  use Util.MakeEnumerable

  def jason(), do: []

  typedstruct enforce: true do
    field(:key, atom())
    field(:firstname_repo, %{})
    field(:lastname_repo, String.t())
  end

  def specs do
    "Elixir." <> module = Atom.to_string(__MODULE__)
    module = "#{module}.Content"

    [
      %{metadata: [], content_name: "culture", module: module, sources: nil}
    ]
  end
end
