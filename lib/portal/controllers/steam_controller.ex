defmodule Portal.SteamController do
  use Portal, :controller

  require Logger

  alias RC.Accounts

  @headers [{"Content-Type", "application/json"}]

  action_fallback(Portal.FallbackController)

  def ticket_auth(conn, %{"ticket" => ticket}) do
    with {:ok, steamid} <- ticket_check(ticket),
         {:ok, summaries} <- player_summaries([steamid]),
         %{personaname: personaname, steamid: steamid} <- summaries |> List.first(),
         {:ok, result} <- signup(%{ticket: ticket, personaname: personaname, steamid: steamid}) do
      conn
      |> put_status(200)
      |> json(%{steamid: steamid, result: result})
    else
      err ->
        Logger.error(inspect(err))

        conn
        |> put_status(500)
        |> json(%{"error" => "Steam API error"})
    end
  end

  defp signup(%{ticket: ticket, steamid: steamid, personaname: personaname}) do
    account_params = %{
      steam_id: steamid,
      name: personaname,
      role: :user,
      status: :active,
      hashed_password: "",
      email: "#{steamid}@steam"
    }

    with {:error, _} <- Accounts.get_account_by_steam_ticket(steamid, ticket),
         {:ok, %{account: _account}} <- Accounts.run_steam_signup_transaction(account_params) do
      {:ok, :created}
    else
      {:ok, _account} ->
        {:ok, :found}

      {:error, failed_operation, failed_value, changes_so_far} ->
        err = %{
          failed_operation: failed_operation,
          failed_value: failed_value,
          changes_so_far: changes_so_far
        }

        Logger.error(inspect(err))
        err

      err ->
        Logger.error(inspect(err))
        err
    end
  end

  def ticket_check(ticket) do
    params = %{
      key: Application.get_env(:rc, :steamworks_web_api_secret, ""),
      appid: 1_393_660,
      ticket: ticket
    }

    url =
      "https://api.steampowered.com/ISteamUserAuth/AuthenticateUserTicket/v1/?" <>
        URI.encode_query(params)

    # Response:
    # %{
    #   "response" => %{
    #     "params" => %{
    #       "ownersteamid" => "76561198…",
    #       "publisherbanned" => false,
    #       "result" => "OK",
    #       "steamid" => "76561198…",
    #       "vacbanned" => false
    #     }
    #   }
    # }

    with {:ok, %{"response" => response}} <- get(url),
         true <- not Map.has_key?(response, "error") or Map.fetch!(response, "error"),
         %{
           "params" => %{
             "publisherbanned" => publisherbanned,
             "steamid" => steamid,
             "vacbanned" => vacbanned
           }
         } = response,
         true <- publisherbanned == false or :banned,
         true <- vacbanned == false or :vacbanned do
      {:ok, steamid}
    else
      :banned ->
        Logger.error(inspect(:banned))
        {:error, :banned}

      :vacbanned ->
        Logger.error(inspect(:vacbanned))
        {:error, :vacbanned}

      err ->
        Logger.error(inspect(err))
        {:error, err}
    end
  end

  defp player_summaries(steamids) when is_list(steamids) do
    params = %{
      key: Application.get_env(:rc, :steamworks_web_api_secret, ""),
      steamids: Enum.join(steamids, ",")
    }

    url =
      "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/?" <>
        URI.encode_query(params)

    # Response:
    # %{
    #   "response" => %{
    #     "players" => [
    #       %{
    #         "avatar" => "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb.jpg",
    #         "avatarfull" => "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb_full.jpg",
    #         "avatarhash" => "fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb",
    #         "avatarmedium" => "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb_medium.jpg",
    #         "communityvisibilitystate" => 3,
    #         "personaname" => "UmamiSteak",
    #         "personastate" => 1,
    #         "personastateflags" => 0,
    #         "primaryclanid" => "103582791429…",
    #         "profilestate" => 1,
    #         "profileurl" => "https://steamcommunity.com/id/umamisteak/",
    #         "steamid" => "76561198…",
    #         "timecreated" => 1286293492
    #       }
    #     ]
    #   }
    # }

    case get(url) do
      {:ok, %{"response" => %{"players" => players}}} ->
        summaries =
          Enum.map(players, fn %{"personaname" => personaname, "steamid" => steamid} ->
            %{personaname: personaname, steamid: steamid}
          end)

        {:ok, summaries}

      _ ->
        {:error, :cannot_get_players_summary}
    end
  end

  defp get(url) do
    case HTTPoison.get(url, @headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Poison.decode(body)

      {:ok, %HTTPoison.Response{status_code: status_code, body: _body}} ->
        Logger.error({:error, status_code})
        {:error, status_code}

      {:error, error} ->
        Logger.error({:error, error})
        {:error, error}
    end
  end
end
