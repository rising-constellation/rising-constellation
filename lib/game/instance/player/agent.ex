defmodule Instance.Player.Agent do
  use Core.TickServer

  require Logger

  alias Instance.Character.{ActionQueue, Character}
  alias Instance.Player.Player
  alias Instance.Player.Market
  alias Instance.StellarSystem.StellarSystem
  alias Portal.Controllers.PlayerChannel

  @decorate tick()
  def on_call(:get_state, _from, state) do
    {:reply, {:ok, state.data}, state}
  end

  def on_call(:get_public_state, _from, state) do
    db_profile = RC.Accounts.get_profile(state.data.id)
    public_player = Instance.Player.PublicPlayer.new(state.data, db_profile)

    {:reply, {:ok, public_player}, state}
  end

  def on_call({:update_client_status, status}, _from, state) do
    data = Player.update_client_status(state.data, status)

    if data.connected_clients > 0 do
      {notifs, data} = Player.flush_notification(data)

      unless Enum.empty?(notifs), do: PlayerChannel.broadcast_change(state.channel, %{player_notifs: notifs})

      {:reply, :ok, %{state | data: data}}
    else
      {:reply, :ok, %{state | data: data}}
    end
  end

  @decorate tick()
  def on_call(:claim_initial_system, _, state) do
    system = Game.call(state.instance_id, :galaxy, :master, {:claim_initial_system, state.data})
    {:ok, data} = Player.add_stellar_system(state.data, system)

    system_bonuses = Player.extract_bonus(data, [:stellar_system])
    system = Game.call(state.instance_id, :stellar_system, system.id, {:update_bonuses, :player, system_bonuses})
    data = Player.update_stellar_system(data, system)

    {:reply, data, %{state | data: data}}
  end

  @decorate tick()
  def on_call({:transform_system_to_dominion, system_id}, _, state) do
    with true <- Player.own_system?(state.data, system_id),
         true <- Player.can_transform_system(state.data),
         true <- Player.can_remove_stellar_system(state.data),
         true <- Player.can_add_dominion(state.data),
         {:ok, system} <- Game.call(state.instance_id, :galaxy, :master, {:claim_system, state.data, system_id, true}),
         {:ok, data} <- prepare_leaving_system(state, system_id),
         {:ok, data} <- Player.pay_transform_system(data),
         {:ok, data} <- Player.remove_stellar_system(data, system_id),
         {:ok, data} <- Player.add_dominion(data, system) do
      PlayerChannel.broadcast_change(state.channel, %{player_player: data})
      {:reply, :ok, %{state | data: data}}
    else
      false ->
        {:reply, {:error, :system_not_found}, state}

      {:error, reason} ->
        Logger.error(":transform_system_to_dominion #{inspect(reason)}")
        {:reply, {:error, reason}, state}

      reason ->
        Logger.error(":transform_system_to_dominion #{inspect(reason)}")
        {:reply, {:error, :system_not_found}, state}
    end
  end

  @decorate tick()
  def on_call({:transform_dominion_to_system, system_id}, _, state) do
    with true <- Player.own_dominion?(state.data, system_id),
         true <- Player.can_transform_system(state.data),
         true <- Player.can_add_stellar_system(state.data),
         {:ok, system} <- Game.call(state.instance_id, :galaxy, :master, {:claim_system, state.data, system_id, false}),
         {:ok, data} <- Player.pay_transform_system(state.data),
         {:ok, data} <- Player.remove_dominion(data, system_id),
         {:ok, data} <- Player.add_stellar_system(data, system) do
      PlayerChannel.broadcast_change(state.channel, %{player_player: data})
      {:reply, :ok, %{state | data: data}}
    else
      false ->
        {:reply, {:error, :system_not_found}, state}

      {:error, reason} ->
        Logger.error(":transform_dominion_to_system #{inspect(reason)}")
        {:reply, {:error, reason}, state}

      reason ->
        Logger.error(":transform_dominion_to_system #{inspect(reason)}")
        {:reply, {:error, :system_not_found}, state}
    end
  end

  @decorate tick()
  def on_call({:abandon_system, system_id}, _, state) do
    with true <- Player.own_system?(state.data, system_id),
         true <- Player.can_abandon_system(state.data),
         true <- Player.can_remove_stellar_system(state.data),
         {:ok, _system} <- Game.call(state.instance_id, :galaxy, :master, {:abandon_system, system_id}),
         {:ok, data} <- prepare_leaving_system(state, system_id),
         {:ok, data} <- Player.pay_abandon_system(data),
         {:ok, data} <- Player.remove_stellar_system(data, system_id) do
      PlayerChannel.broadcast_change(state.channel, %{player_player: data})
      {:reply, :ok, %{state | data: data}}
    else
      false ->
        {:reply, {:error, :system_not_found}, state}

      {:error, reason} ->
        Logger.error(":abandon_system #{inspect(reason)}")
        {:reply, {:error, reason}, state}

      reason ->
        Logger.error(":abandon_system #{inspect(reason)}")
        {:reply, {:error, :system_not_found}, state}
    end
  end

  @decorate tick()
  def on_call({:abandon_dominion, system_id}, _, state) do
    with true <- Player.own_dominion?(state.data, system_id),
         true <- Player.can_abandon_system(state.data),
         {:ok, _system} <- Game.call(state.instance_id, :galaxy, :master, {:abandon_system, system_id}),
         {:ok, data} <- Player.pay_abandon_system(state.data),
         {:ok, data} <- Player.remove_dominion(data, system_id) do
      PlayerChannel.broadcast_change(state.channel, %{player_player: data})
      {:reply, :ok, %{state | data: data}}
    else
      false -> {:reply, {:error, :system_not_found}, state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @decorate tick()
  def on_call({:add_resources, credit, technology, ideology}, _, state) do
    data =
      state.data
      |> Player.add_credit(credit)
      |> Player.add_technology(technology)
      |> Player.add_ideology(ideology)

    PlayerChannel.broadcast_change(state.channel, %{player_player: data})

    {:reply, :ok, %{state | data: data}}
  end

  @decorate tick()
  def on_call({:order_building, system_id, type, production_data}, _, state) do
    with {:ok, _} <- Player.order_building(state.data, system_id, type, production_data, true),
         {:ok, system} <-
           Game.call(state.instance_id, :stellar_system, system_id, {:order_building, type, production_data}),
         {:ok, data} <- Player.order_building(state.data, system_id, type, production_data) do
      data = Player.update_stellar_system(data, system)
      PlayerChannel.broadcast_change(state.channel, %{player_player: data})

      {:reply, data, %{state | data: data}}
    else
      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @decorate tick()
  def on_call({:order_ship, system_id, production_data}, _, state) do
    with {:ok, _} <- Player.order_ship(state.data, system_id, production_data, true),
         {:ok, character, system} <-
           Game.call(state.instance_id, :stellar_system, system_id, {:order_ship, production_data}),
         {:ok, data} <- Player.order_ship(state.data, system_id, production_data) do
      data =
        data
        |> Player.update_character(character)
        |> Player.update_stellar_system(system)

      PlayerChannel.broadcast_change(state.channel, %{player_player: data})

      {:reply, data, %{state | data: data}}
    else
      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @decorate tick()
  def on_call({:remove_building, system_id, production_data}, _, state) do
    with true <- Player.own_system?(state.data, system_id),
         request = {:remove_building, production_data},
         {:ok, system} <- Game.call(state.instance_id, :stellar_system, system_id, request) do
      data = Player.update_stellar_system(state.data, system)
      PlayerChannel.broadcast_change(state.channel, %{player_player: data})

      {:reply, data, %{state | data: data}}
    else
      {:error, reason} -> {:reply, {:error, reason}, state}
      _ -> {:reply, {:error, :system_not_found}, state}
    end
  end

  @decorate tick()
  def on_call({:destroy_ship, character_id, tile_id}, _, state) do
    with true <- Player.own_character?(state.data, character_id),
         character <- Enum.find(state.data.characters, fn c -> c.id == character_id end),
         true <- not character.on_sold,
         request = {:destroy_ship, tile_id},
         {:ok, character} <- Game.call(state.instance_id, :character, character_id, request) do
      data = Player.update_character(state.data, character)
      PlayerChannel.broadcast_change(state.channel, %{player_player: data})

      {:reply, data, %{state | data: data}}
    else
      {:error, reason} -> {:reply, {:error, reason}, state}
      _ -> {:reply, {:error, :system_not_found}, state}
    end
  end

  @decorate tick()
  def on_call({:cancel_production, system_id, production_id}, _, state) do
    with true <- Player.own_system?(state.data, system_id),
         {credit, technology, system} <-
           Game.call(state.instance_id, :stellar_system, system_id, {:cancel_production, production_id}) do
      data =
        state.data
        |> Player.add_credit(credit)
        |> Player.add_technology(technology)
        |> Player.update_stellar_system(system)

      PlayerChannel.broadcast_change(state.channel, %{player_player: data})
      {:reply, data, %{state | data: data}}
    else
      false ->
        {:reply, {:error, :system_not_found}, state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @decorate tick()
  def on_call({:purchase_patent, patent_key}, _, state) do
    case Player.purchase_patent(state.data, patent_key) do
      {:ok, data} ->
        PlayerChannel.broadcast_change(state.channel, %{player_player: data})
        {:reply, :ok, %{state | data: data}}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @decorate tick()
  def on_call({:purchase_doctrine, doctrine_key}, _, state) do
    case Player.purchase_doctrine(state.data, doctrine_key) do
      {:ok, data} ->
        PlayerChannel.broadcast_change(state.channel, %{player_player: data})
        {:reply, :ok, %{state | data: data}}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @decorate tick()
  def on_call(:purchase_policy_slot, _, state) do
    case Player.purchase_policy_slot(state.data) do
      {:ok, data} ->
        PlayerChannel.broadcast_change(state.channel, %{player_player: data})
        {:reply, :ok, %{state | data: data}}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @decorate tick()
  def on_call({:update_policies, doctrines_key}, _, state) do
    case Player.update_policies(state.data, doctrines_key) do
      {:ok, data, system_bonuses, character_bonuses} ->
        # TODO: propagate to systems, dominions, and characters in parallel

        # propagate doctrine to stellar systems
        data =
          Enum.reduce(data.stellar_systems, data, fn system, acc ->
            request = {:update_bonuses, :player, system_bonuses}
            new_system = Game.call(state.instance_id, :stellar_system, system.id, request)
            Player.update_stellar_system(acc, new_system)
          end)

        # propagate doctrine to dominions
        data =
          Enum.reduce(data.dominions, data, fn system, acc ->
            request = {:update_bonuses, :player, system_bonuses}
            new_system = Game.call(state.instance_id, :stellar_system, system.id, request)
            Player.update_dominion(acc, new_system)
          end)

        # propagate doctrine to characters
        data =
          data.characters
          |> Enum.filter(fn character -> character.status == :on_board end)
          |> Enum.reduce(data, fn character, acc ->
            request = {:update_bonuses, :player, character_bonuses}
            new_character = Game.call(state.instance_id, :character, character.id, request)
            Player.update_character(acc, new_character)
          end)

        PlayerChannel.broadcast_change(state.channel, %{player_player: data})
        {:reply, :ok, %{state | data: data}}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @decorate tick()
  def on_call({:hire_character, character}, _, state) do
    resources = {character["credit_cost"], character["technology_cost"], character["ideology_cost"]}

    with :ok <- Player.check_hire_character(state.data, resources),
         {:ok, character} <-
           Game.call(state.instance_id, :character_market, :master, {:sell_character, character["id"]}),
         {:ok, data} <- Player.hire_character(state.data, resources, character) do
      PlayerChannel.broadcast_change(state.channel, %{player_player: data})

      {:reply, data, %{state | data: data}}
    else
      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @decorate tick()
  def on_call({:dismiss_character, character_id}, _, state) do
    case Player.dismiss_character(state.data, character_id) do
      {:ok, data} ->
        PlayerChannel.broadcast_change(state.channel, %{player_player: data})
        {:reply, data, %{state | data: data}}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @decorate tick()
  def on_call({:transfer_character, character_id}, _, state) do
    case Player.transfer_character(state.data, character_id) do
      {:ok, data} ->
        PlayerChannel.broadcast_change(state.channel, %{player_player: data})
        {:reply, {:ok, data}, %{state | data: data}}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @decorate tick()
  def on_call({:activate_character, character_id, mode, system_id}, _, state) do
    case Player.activate_character(state.data, character_id, mode, system_id) do
      {:ok, data, character} ->
        state = %{state | data: data}

        # reset strike status before activation
        character = Character.update_strike(character, data.is_bankrupt)

        {:ok, supervisor_pid} = Instance.Supervisor.get_pid(state.instance_id)
        channel = "instance:player:#{state.instance_id}:#{data.id}"
        character_gen_state = Core.GenState.new(:character, state.instance_id, character.id, character, channel)

        DynamicSupervisor.start_child(supervisor_pid, {Instance.Character.Agent, state: character_gen_state})

        {:ok, time} = Game.call(state.instance_id, :time, :master, :get_state)

        if time.is_running do
          :ok = Game.call(state.instance_id, :character, character.id, {:start, state.tick.cumulated_pauses})
        end

        case Game.call(state.instance_id, :stellar_system, system_id, {:push_character, character, mode}) do
          {:error, reason} ->
            {:reply, {:error, reason}, state}

          {:ok, system} ->
            data = Player.update_stellar_system(data, system)

            # propagate doctrine to characters
            bonuses = Player.extract_bonus(data, [:character, :army, :spy, :speaker])
            character = Game.call(state.instance_id, :character, character.id, {:update_bonuses, :player, bonuses})
            data = Player.update_character(data, character)

            state = next_tick(%{state | data: data})

            PlayerChannel.broadcast_change(state.channel, %{player_player: data})

            {:reply, state.data, state}
        end

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @decorate tick()
  def on_call({:deactivate_character, character_id}, _, state) do
    case deactivate_character(state, character_id, true) do
      {:ok, state} -> {:reply, state.data, state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @decorate tick()
  def on_call({:assassinate_character, character_id}, _, state) do
    if Player.own_character?(state.data, character_id) do
      {:ok, character} = Game.call(state.instance_id, :character, character_id, :get_state)

      if character.status == :on_board and character.type == :admiral and
           (Character.has_planned_ship?(character) or Character.has_ship?(character)) do
        character = Character.replace_agent_with_default(character, state.instance_id)
        Game.cast(state.instance_id, :character, character_id, {:update_state, character})
        Game.cast(state.instance_id, :stellar_system, character.system, {:update_character, character})
        {:ok, system} = Game.call(state.instance_id, :stellar_system, character.system, :get_state)

        data =
          state.data
          |> Player.update_character(character)
          |> Player.update_stellar_system(system)

        state = next_tick(%{state | data: data})
        PlayerChannel.broadcast_change(state.channel, %{player_player: state.data})

        {:reply, :ok, state}
      else
        with {:ok, data, _character} <- Player.assassinate_character(state.data, character),
             state = %{state | data: data},
             {:ok, system} <-
               Game.call(
                 state.instance_id,
                 :stellar_system,
                 character.system,
                 {:remove_character, character, character.status}
               ) do
          Instance.Manager.kill_child(state.instance_id, {state.instance_id, :character, character.id})
          data = Player.update_stellar_system(data, system)

          state = next_tick(%{state | data: data})
          PlayerChannel.broadcast_change(state.channel, %{player_player: state.data})

          {:reply, :ok, state}
        else
          {:error, reason} -> {:reply, {:error, reason}, state}
          error -> {:reply, {:error, error}, state}
        end
      end
    else
      {:reply, {:error, :character_not_found}, state}
    end
  end

  @decorate tick()
  def on_call({:convert_character, character, system_id}, _, state) do
    {:ok, character_id} = Game.call(state.instance_id, :character_market, :master, :get_next_character_id)
    {:ok, data, character} = Player.convert_character(state.data, character, character_id, system_id)
    state = %{state | data: data}

    # reset strike status before activation
    character = Character.update_strike(character, data.is_bankrupt)

    {:ok, supervisor_pid} = Instance.Supervisor.get_pid(state.instance_id)
    channel = "instance:player:#{state.instance_id}:#{data.id}"
    character_gen_state = Core.GenState.new(:character, state.instance_id, character.id, character, channel)

    DynamicSupervisor.start_child(supervisor_pid, {Instance.Character.Agent, state: character_gen_state})

    {:ok, time} = Game.call(state.instance_id, :time, :master, :get_state)

    if time.is_running do
      :ok = Game.call(state.instance_id, :character, character.id, {:start, state.tick.cumulated_pauses})
    end

    case Game.call(state.instance_id, :stellar_system, system_id, {:push_character, character, :on_board}) do
      {:error, reason} ->
        {:reply, {:error, reason}, state}

      {:ok, _system} ->
        PlayerChannel.broadcast_change(state.channel, %{player_player: data})
        {:reply, :ok, state}
    end
  end

  @decorate tick()
  def on_call({:add_character_actions, character_id, actions}, _, state) do
    with true <- Player.own_character?(state.data, character_id),
         character <- Enum.find(state.data.characters, fn c -> c.id == character_id end),
         true <- not character.on_sold,
         :ok <- Game.call(state.instance_id, :character, character_id, {:add_actions, actions}) do
      {:reply, :ok, state}
    else
      false ->
        {:reply, {:error, :character_not_found}, state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @decorate tick()
  def on_call({:clear_character_actions, character_id, index}, _, state) do
    with true <- Player.own_character?(state.data, character_id),
         character <- Enum.find(state.data.characters, fn c -> c.id == character_id end),
         true <- not character.on_sold do
      Game.cast(state.instance_id, :character, character_id, {:clear_actions, index})
      {:reply, :ok, state}
    else
      _ ->
        {:reply, {:error, :character_not_found}, state}
    end
  end

  @decorate tick()
  def on_call({:get_character_state, character_id}, _, state) do
    with true <- Player.own_character?(state.data, character_id),
         {:ok, character} <- Game.call(state.instance_id, :character, character_id, :get_state) do
      actions = ActionQueue.skip_initial_lock(character.actions)
      character = %{character | actions: actions}
      {:reply, character, state}
    else
      false ->
        {:reply, {:error, :character_not_found}, state}

      err ->
        Logger.error(":get_character_state #{inspect(err)}")
        {:reply, {:error, :character_not_found}, state}
    end
  end

  @decorate tick()
  def on_call({:update_reaction, character_id, reaction}, _, state) do
    with true <- Player.own_character?(state.data, character_id),
         character <- Enum.find(state.data.characters, fn c -> c.id == character_id end),
         true <- not character.on_sold,
         {:ok, character} <- Game.call(state.instance_id, :character, character_id, {:update_reaction, reaction}) do
      data = Player.update_character(state.data, character)
      PlayerChannel.broadcast_change(state.channel, %{player_player: data})

      {:reply, state.data, state}
    else
      false ->
        {:reply, {:error, :character_not_found}, state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @decorate tick()
  def on_call({:fight_callback, status, %Character{} = character}, _, state) do
    {data, character, has_to_die?} = fight_callback(status, state, character)

    {:reply, {character, has_to_die?}, %{state | data: data}}
  end

  @decorate tick()
  def on_call({:create_offer, offer_data}, _, state) do
    case Market.create_offer(state.data, offer_data) do
      {:ok, data} ->
        PlayerChannel.broadcast_change(state.channel, %{player_player: data})
        {:reply, :ok, %{state | data: data}}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @decorate tick()
  def on_call({:cancel_offer, offer_id}, _, state) do
    case Market.cancel_offer(state.data, offer_id) do
      {:ok, data} ->
        PlayerChannel.broadcast_change(state.channel, %{player_player: data})
        {:reply, :ok, %{state | data: data}}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @decorate tick()
  def on_call({:buy_offer, offer_id}, _, state) do
    case Market.buy_offer(state.data, offer_id) do
      {:ok, data, seller_id, amount} ->
        Game.call(state.instance_id, :player, seller_id, {:add_resources, amount, 0, 0})

        notif = Notification.Text.new(:offer_sold, nil, %{buyer: state.data.name, offer_id: offer_id})
        Game.cast(state.instance_id, :player, seller_id, {:push_notifs, notif})

        PlayerChannel.broadcast_change(state.channel, %{player_player: data})
        {:reply, :ok, %{state | data: data}}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @decorate tick()
  def on_cast({:claim_system, system_id}, state) do
    with true <- Player.can_add_stellar_system(state.data),
         {:ok, system} <- Game.call(state.instance_id, :galaxy, :master, {:claim_system, state.data, system_id, false}),
         {:ok, data} <- Player.add_stellar_system(state.data, system) do
      # update newly claimed system with existing bonuses
      system_bonuses = Player.extract_bonus(data, [:stellar_system])
      system = Game.call(state.instance_id, :stellar_system, system.id, {:update_bonuses, :player, system_bonuses})
      data = Player.update_stellar_system(data, system)

      PlayerChannel.broadcast_change(state.channel, %{player_player: data})
      {:noreply, %{state | data: data}}
    else
      {:error, reason} ->
        Logger.error(":claim_system #{inspect(reason)}")
        {:noreply, state}

      reason ->
        Logger.error(":claim_system #{inspect(reason)}")
        {:noreply, state}
    end
  end

  @decorate tick()
  def on_cast({:claim_dominion, system_id}, state) do
    with true <- Player.can_add_dominion(state.data),
         {:ok, system} <- Game.call(state.instance_id, :galaxy, :master, {:claim_system, state.data, system_id, true}),
         {:ok, data} <- Player.add_dominion(state.data, system) do
      # update newly claimed system with existing bonuses
      system_bonuses = Player.extract_bonus(data, [:stellar_system])
      system = Game.call(state.instance_id, :stellar_system, system.id, {:update_bonuses, :player, system_bonuses})
      data = Player.update_dominion(data, system)

      PlayerChannel.broadcast_change(state.channel, %{player_player: data})
      {:noreply, %{state | data: data}}
    else
      {:error, reason} ->
        Logger.error(":claim_dominion #{inspect(reason)}")
        {:noreply, state}

      reason ->
        Logger.error(":claim_dominion #{inspect(reason)}")
        {:noreply, state}
    end
  end

  @decorate tick()
  def on_cast({:lose_system, system_id}, state) do
    with true <- Player.own_system?(state.data, system_id),
         system when not is_nil(system) <- Enum.find(state.data.stellar_systems, fn s -> s.id == system_id end),
         {:ok, data} <- prepare_leaving_system(state, system_id),
         {:ok, data} <- Player.remove_stellar_system(data, system_id) do
      if data.is_dead do
        RC.Instances.kill_player(data.faction_id, data.id)
      end

      state = %{state | data: data}

      PlayerChannel.broadcast_change(state.channel, %{player_player: state.data})

      {:noreply, state}
    else
      err ->
        Logger.error(":lose_system #{inspect(err)}")
        {:noreply, state}
    end
  end

  @decorate tick()
  def on_cast({:lose_dominion, system_id}, state) do
    with true <- Player.own_dominion?(state.data, system_id),
         system when not is_nil(system) <- Enum.find(state.data.dominions, fn s -> s.id == system_id end),
         {:ok, data} <- Player.remove_dominion(state.data, system_id) do
      state = %{state | data: data}
      PlayerChannel.broadcast_change(state.channel, %{player_player: state.data})

      {:noreply, state}
    else
      err ->
        Logger.error(":lose_dominion #{inspect(err)}")
        {:noreply, state}
    end
  end

  @decorate tick()
  def on_cast({:update_system, %StellarSystem{} = system}, state) do
    data = Player.update_stellar_system(state.data, system)
    state = next_tick(%{state | data: data})

    PlayerChannel.broadcast_change(state.channel, %{player_player: state.data})

    {:noreply, state}
  end

  @decorate tick()
  def on_cast({:update_dominion, %StellarSystem{} = system}, state) do
    data = Player.update_dominion(state.data, system)
    state = next_tick(%{state | data: data})

    PlayerChannel.broadcast_change(state.channel, %{player_player: state.data})

    {:noreply, state}
  end

  @decorate tick()
  def on_cast({:update_character, %Character{status: :governor} = character}, state) do
    data = Player.update_character(state.data, character)
    state = %{state | data: data}

    case Game.call(state.instance_id, :stellar_system, character.system, {:push_character, character, :governor}) do
      {:ok, system} ->
        data = Player.update_stellar_system(data, system)
        state = next_tick(%{state | data: data})

        PlayerChannel.broadcast_change(state.channel, %{player_player: state.data})

        {:noreply, state}

      {:error, _} ->
        {:noreply, state}
    end
  end

  @decorate tick()
  def on_cast({:update_character, %Character{} = character}, state) do
    data = Player.update_character(state.data, character)
    state = %{state | data: data} |> next_tick()

    characters =
      Enum.map(state.data.characters, fn character ->
        actions = ActionQueue.skip_initial_lock(character.actions)
        %{character | actions: actions}
      end)

    data = %{state.data | characters: characters}
    PlayerChannel.broadcast_change(state.channel, %{player_player: data})

    {:noreply, state}
  end

  def on_cast({:push_notifs, []}, state), do: {:noreply, state}

  def on_cast({:push_notifs, notif}, state) when not is_list(notif),
    do: on_cast({:push_notifs, [notif]}, state)

  def on_cast({:push_notifs, notifs}, state) do
    data =
      Enum.reduce(notifs, state.data, fn notif, acc ->
        if state.speed != :fast do
          save_event(acc.instance_id, acc.registration_id, notif)
        end

        if state.data.connected_clients == 0 and notif.keep?,
          do: Player.store_notification(acc, notif),
          else: acc
      end)

    unless Enum.empty?(notifs), do: PlayerChannel.broadcast_change(state.channel, %{player_notifs: notifs})

    {:noreply, %{state | data: data}}
  end

  @decorate tick()
  def on_info(:tick, state) do
    {:noreply, state}
  end

  defp do_next_tick(state, elapsed_time) do
    {change, data} = Player.next_tick(state.data, elapsed_time)

    if MapSet.member?(change, :make_stats) do
      {:ok, galaxy} = Game.call(state.instance_id, :galaxy, :master, :get_state)

      unless Instance.Galaxy.Galaxy.is_tutorial(galaxy) do
        Player.get_stats(data)
        |> RC.PlayerStats.create_player_stat()
      end
    end

    if MapSet.member?(change, :player_update) do
      PlayerChannel.broadcast_change(state.channel, %{player_player: data})
    end

    if MapSet.member?(change, :update_player_activity) do
      Game.cast(state.instance_id, :galaxy, :master, {:add_player, data})
    end

    {%{state | data: data}, Player}
  end

  defp clear_associated_production_queue(%Player{} = player, character_id) do
    character = Game.call(player.instance_id, :character, character_id, :cancel_all_ships)
    Game.cast(player.instance_id, :stellar_system, character.system, {:cancel_ordered_ships, character.id})

    Player.update_character(player, character)
  end

  defp deactivate_character(state, nil, _broadcast?),
    do: {:ok, state}

  defp deactivate_character(state, character_id, broadcast?) do
    with {:ok, character} <- Game.call(state.instance_id, :character, character_id, :get_state),
         mode = character.status,
         system_id = character.system,
         {:ok, data, character} <- Player.deactivate_character(state.data, character),
         state = %{state | data: data},
         :ok <- Instance.Manager.kill_child(state.instance_id, {state.instance_id, :character, character.id}),
         {:ok, system} <- Game.call(state.instance_id, :stellar_system, system_id, {:remove_character, character, mode}) do
      data = Player.update_stellar_system(data, system)
      state = next_tick(%{state | data: data})

      if broadcast? do
        PlayerChannel.broadcast_change(state.channel, %{player_player: state.data})
      end

      {:ok, state}
    else
      {:error, reason} ->
        {:error, reason}

      error ->
        {:error, error}
    end
  end

  defp fight_callback(:victorious, state, character) do
    data = Player.update_character(state.data, character)
    Game.cast(state.instance_id, :character, character.id, {:update_state, character})

    {data, character, false}
  end

  defp fight_callback(:fleeing, state, character) do
    if Enum.member?([:conquest, :raid, :loot], character.action_status) do
      {:ok, _system, _siege_logs} =
        Game.call(character.instance_id, :stellar_system, character.system, {:release_siege, 0, 0})
    end

    Game.cast(state.instance_id, :character, character.id, {:update_state, character})
    character = Game.call(state.instance_id, :character, character.id, :flee)

    data =
      state.data
      |> clear_associated_production_queue(character.id)
      |> Player.update_character(character)

    {data, character, false}
  end

  defp fight_callback(:dead, state, character) do
    if Enum.member?([:conquest, :raid, :loot], character.action_status) do
      {:ok, _system, _siege_logs} =
        Game.call(character.instance_id, :stellar_system, character.system, {:release_siege, 0, 0})
    end

    data =
      state.data
      |> clear_associated_production_queue(character.id)
      |> Player.kill_character(character)

    # we need to do that there because the character process will no longer be active
    # therefore the player will not receive a signal telling it to broadcast new state
    PlayerChannel.broadcast_change(state.channel, %{player_player: data})

    {data, character, true}
  end

  defp prepare_leaving_system(state, system_id) do
    system = Enum.find(state.data.stellar_systems, fn s -> s.id == system_id end)

    # deactivate governor if any
    with governor_id <- if(system.governor == nil, do: nil, else: system.governor.id),
         {:ok, state} <- deactivate_character(state, governor_id, false) do
      data =
        system.characters
        |> Enum.reduce(state.data, fn
          # clear admiral production queues
          c, data when c.type == :admiral and c.owner.id == state.data.id ->
            clear_associated_production_queue(data, c.id)

          _, data ->
            data
        end)

      {:ok, data}
    else
      _ -> :error
    end
  end

  def save_event(_iid, _rid, %Notification.Notification{type: :sound} = _notif),
    do: nil

  def save_event(iid, rid, %Notification.Notification{} = notif) do
    RC.PlayerEvents.create(%{
      type: Atom.to_string(notif.type),
      key: Atom.to_string(notif.key),
      data: Jason.encode!(notif.data),
      instance_id: iid,
      registration_id: rid
    })
  end
end
