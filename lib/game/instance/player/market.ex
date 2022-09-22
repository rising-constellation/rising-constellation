defmodule Instance.Player.Market do
  alias Instance.Player.Player
  alias Instance.Character.Character

  def create_offer(state, %{
        "type" => type,
        "data" => data,
        "price" => price,
        "allowed_players" => allowed_players,
        "allowed_factions" => allowed_factions
      })
      when price >= 0 do
    case place_offer(state, type, data) do
      {:ok, state, data, internal, value} ->
        price = Enum.max([price, 0])
        price = Enum.min([price, 1_000_000_000])

        attrs = %{
          type: type,
          data: data,
          internal: internal,
          price: price,
          profile_id: state.id,
          instance_id: state.instance_id,
          value: value
        }

        cond do
          length(allowed_players) > 0 ->
            RC.Offers.create_for_allowed_players(attrs, allowed_players)

          length(allowed_factions) > 0 ->
            RC.Offers.create_for_allowed_factions(attrs, allowed_factions)

          true ->
            RC.Offers.create(attrs)
        end

        {:ok, state}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def create_offer(_state, _args) do
    {:error, :bad_argument}
  end

  def cancel_offer(state, offer_id) do
    offer = RC.Offers.get_offer(offer_id)
    current_status = offer.status

    with %RC.Instances.Offer{} = offer <- offer,
         true <- offer.profile_id == state.id,
         true <- offer.status == "active",
         _ <- RC.Offers.update_offer_status(offer, "inactive"),
         {:ok, state} <- unplace_offer(state, offer.type, offer) do
      {:ok, state}
    else
      _ ->
        RC.Offers.get_offer(offer_id)
        |> RC.Offers.update_offer_status(current_status)

        {:error, :offer_not_found}
    end
  end

  def buy_offer(state, offer_id) do
    c = Data.Querier.one(Data.Game.Constant, state.instance_id, :main)
    offer = RC.Offers.get_offer(offer_id)
    current_status = offer.status

    with %RC.Instances.Offer{} = offer <- offer,
         true <- offer.profile_id != state.id,
         true <- offer.status == "active",
         {:ok, offer} <- RC.Offers.update_offer_status(offer, "sold"),
         final_price <- offer.price + c.market_taxe * offer.value,
         true <- state.credit.value >= final_price,
         {:ok, state} <- transfer_offer(state, offer.type, offer) do
      state = Player.add_credit(state, -final_price)
      {:ok, state, offer.profile_id, offer.price}
    else
      false ->
        RC.Offers.get_offer(offer_id)
        |> RC.Offers.update_offer_status(current_status)

        {:error, :not_enough_credit}

      {:error, reason} ->
        RC.Offers.get_offer(offer_id)
        |> RC.Offers.update_offer_status(current_status)

        {:error, reason}

      _error ->
        RC.Offers.get_offer(offer_id)
        |> RC.Offers.update_offer_status(current_status)

        {:error, :offer_not_found}
    end
  end

  defp place_offer(state, "technology", data) do
    with true <- Map.has_key?(data, "amount"),
         amount <- Map.get(data, "amount"),
         true <- is_number(amount),
         true <- state.technology.value >= amount do
      value = amount * 10
      state = Player.add_technology(state, -amount)
      {:ok, state, Jason.encode!(data), nil, value}
    else
      _ -> {:error, :not_enough_technology}
    end
  end

  defp place_offer(state, "ideology", data) do
    with true <- Map.has_key?(data, "amount"),
         amount <- Map.get(data, "amount"),
         true <- is_number(amount),
         true <- state.ideology.value >= amount do
      value = amount * 10
      state = Player.add_ideology(state, -amount)
      {:ok, state, Jason.encode!(data), nil, value}
    else
      _ -> {:error, :not_enough_ideology}
    end
  end

  defp place_offer(state, "character_deck", data) do
    with true <- Map.has_key?(data, "character_id"),
         character_id <- Map.get(data, "character_id"),
         character <- Enum.find(state.character_deck, fn %{character: c} -> c.id == character_id end) do
      %{cooldown: nil, character: character} = character
      value = character.level * 50_000
      data = Map.put(data, "character", character)

      character_deck =
        Enum.map(state.character_deck, fn character_cd ->
          if character_cd.character.id == character_id,
            do: %{character_cd | character: Character.set_on_sold(character_cd.character)},
            else: character_cd
        end)

      state = %{state | character_deck: character_deck}
      {:ok, state, Jason.encode!(data), :erlang.term_to_binary(character), value}
    else
      _ -> {:error, :error}
    end
  end

  defp place_offer(state, "board_character", data) do
    with true <- Map.has_key?(data, "character_id"),
         character_id <- Map.get(data, "character_id"),
         true <- Player.own_character?(state, character_id),
         player_character <- Enum.find(state.characters, fn c -> c.id == character_id end),
         true <- player_character.status == :on_board and player_character.action_status == :idle,
         {:ok, character} <- Game.call(state.instance_id, :character, character_id, {:set_on_sold}) do
      state = Player.update_character(state, character)
      maintenance = if character.type == :admiral, do: character.army.maintenance.value * 250, else: 0
      value = character.level * 50_000 + maintenance
      data = Map.put(data, "character", character)

      {:ok, state, Jason.encode!(data), :erlang.term_to_binary(character), trunc(value)}
    else
      {:error, error} -> {:error, error}
      _ -> {:error, :error}
    end
  end

  defp unplace_offer(state, "technology", offer) do
    data = Jason.decode!(offer.data)
    state = Player.add_technology(state, Map.get(data, "amount"))
    {:ok, state}
  end

  defp unplace_offer(state, "ideology", offer) do
    data = Jason.decode!(offer.data)
    state = Player.add_ideology(state, Map.get(data, "amount"))
    {:ok, state}
  end

  defp unplace_offer(state, "character_deck", offer) do
    data = Jason.decode!(offer.data)
    character_id = Map.get(data, "character_id")

    character_deck =
      Enum.map(state.character_deck, fn character_cd ->
        if character_cd.character.id == character_id,
          do: %{character_cd | character: Character.unset_on_sold(character_cd.character)},
          else: character_cd
      end)

    state = %{state | character_deck: character_deck}
    {:ok, state}
  end

  defp unplace_offer(state, "board_character", offer) do
    data = Jason.decode!(offer.data)
    character_id = Map.get(data, "character_id")
    {:ok, character} = Game.call(state.instance_id, :character, character_id, {:unset_on_sold})
    state = Player.update_character(state, character)
    {:ok, state}
  end

  defp transfer_offer(state, "technology", offer) do
    data = Jason.decode!(offer.data)
    state = Player.add_technology(state, Map.get(data, "amount"))
    {:ok, state}
  end

  defp transfer_offer(state, "ideology", offer) do
    data = Jason.decode!(offer.data)
    state = Player.add_ideology(state, Map.get(data, "amount"))
    {:ok, state}
  end

  defp transfer_offer(state, "character_deck", offer) do
    data = Jason.decode!(offer.data)

    with :ok <- Player.check_hire_character(state, {0, 0, 0}) do
      character = :erlang.binary_to_term(offer.internal)
      character_id = Map.get(data, "character_id")

      new_owner = Instance.Character.Player.convert(state)
      character = %{character | owner: new_owner}
      character_deck = [%{cooldown: nil, character: character} | state.character_deck]
      state = %{state | character_deck: character_deck}
      Game.call(state.instance_id, :player, offer.profile_id, {:dismiss_character, character_id})

      {:ok, state}
    else
      {:error, error} -> {:error, error}
      _ -> {:error, :error}
    end
  end

  defp transfer_offer(state, "board_character", offer) do
    data = Jason.decode!(offer.data)
    character = :erlang.binary_to_term(offer.internal)
    character_id = Map.get(data, "character_id")

    with true <- Player.character_available_slots?(state, character.type),
         {:ok, _} <- Game.call(state.instance_id, :character, character_id, {:update_owner, state}),
         {:ok, character} <- Game.call(state.instance_id, :character, character_id, {:unset_on_sold}),
         {:ok, _} <- Game.call(state.instance_id, :player, offer.profile_id, {:transfer_character, character_id}) do
      characters = state.characters ++ [Instance.Player.Character.convert(character)]
      state = %{state | characters: characters}

      {:ok, state}
    else
      {:error, error} -> {:error, error}
      _ -> {:error, :not_enough_agents_slot}
    end
  end
end
