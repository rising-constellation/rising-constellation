defmodule Instance.Character.ActionImpl do
  @moduledoc """
  Implementations of all `Instance.Character` action
  """
  require Logger

  alias Instance.Character.Character
  alias Instance.Character.Actions

  @actions %{
    jump: Actions.Jump,
    colonization: Actions.Colonization,
    fight: Actions.Fight,
    conquest: Actions.Conquest,
    raid: Actions.Raid,
    loot: Actions.Loot,
    infiltrate: Actions.Infiltrate,
    sabotage: Actions.Sabotage,
    assassination: Actions.Assassination,
    make_dominion: Actions.MakeDominion,
    encourage_hate: Actions.EncourageHate,
    conversion: Actions.Conversion
  }

  @doc """
  Executed right before adding an `Instance.Character.Action` to
  the `Instance.Character.Agent`'s `Instance.Character.ActionQueue`
  """
  def pre_validate_action(%Character{} = character, action) do
    try do
      type = String.to_existing_atom(action["type"])

      case Map.fetch(@actions, type) do
        {:ok, module} -> module.pre_validate(character, action)
        :error -> throw(:action_not_found)
      end
    catch
      reason ->
        unless is_atom(reason) do
          Logger.error(inspect(reason))
        end

        character.actions
    end
  end

  @doc """
  Called by `Instance.Character.Agent.orchestrated/3`, validates and starts an action.
  """
  def on_start(%Character{} = character, action) do
    try do
      case Map.fetch(@actions, action.type) do
        {:ok, module} -> module.start(character, action)
        :error -> throw({:action_not_found, []})
      end
    catch
      {_reason, notifs} ->
        character = Character.abort_action(character)
        {MapSet.new([:player_update]), notifs, character}

      err ->
        Logger.error(inspect(err))
    end
  end

  @doc """
  Called by `Instance.Character.Agent.orchestrated/3`, finishes an action
  """
  def on_finish(%Character{} = character, action) do
    case Map.fetch(@actions, action.type) do
      {:ok, module} ->
        module.finish(character, action)

      :error ->
        Logger.error(Atom.to_string(:action_not_found))
        {MapSet.new([:player_update]), [], character}
    end
  end
end
