defmodule Portal.GameController do
  use Portal, :controller

  alias RC.Instances
  alias RC.Registrations

  require Logger

  def join(conn, %{"iid" => iid, "token" => registration_token}) do
    case Instances.get_instance(iid) do
      nil ->
        response(conn, 404, :instance_not_found)

      instance ->
        if instance.supervisor_status == :running do
          case Registrations.valid?(iid, registration_token) do
            {:ok, registration} ->
              response(conn, 200)
              |> json(%{
                instance: iid,
                faction: registration.faction.id,
                profile: registration.profile_id,
                registration_token: registration_token,
                user_token: Guardian.Plug.current_token(conn)
              })

            {:error, _} ->
              response(conn, 400, :registration_not_valid)
          end
        else
          response(conn, 500, :supervisor_not_running)
        end
    end
  end

  def create_and_join_tutorial(conn, %{"pid" => pid}) do
    # generate an instance id based on the timestamp with 3 random integer
    # this should be sufficient to ensure that no instance_id collision will
    # occure.
    instance_id = :os.system_time(:seconds) * 1000 + :rand.uniform(999)

    profile = RC.Accounts.get_profile(pid)
    instance = tutorial_data(instance_id, profile)

    with {:ok, :instantiated} <- Instance.Manager.create_from_model(instance, profile.id),
         {:ok, :started, _} <- Instance.Manager.call(instance_id, :start) do
      conn
      |> response(200)
      |> json(%{
        instance: instance_id,
        faction: 1,
        profile: profile.id,
        registration_token: RC.Instances.Registration.generate_token(),
        user_token: Guardian.Plug.current_token(conn)
      })
    else
      error ->
        Logger.warn(error)
        response(conn, 400, :registration_not_valid)
    end
  end

  defp response(conn, code) do
    conn
    |> put_status(code)
  end

  defp response(conn, code, message) do
    conn
    |> response(code)
    |> json(%{message: message})
  end

  def tutorial_data(instance_id, profile) do
    registration = %{id: 1, profile: profile}

    %{
      factions: [
        %{id: 1, capacity: 1, faction_ref: "synelle", registrations: [registration]},
        %{id: 2, capacity: 1, faction_ref: "myrmezir", registrations: []}
      ],
      game_data: %{
        "blackholes" => [
          %{
            "key" => 1,
            "name" => "Anova",
            "position" => %{"x" => 38.36930455635492, "y" => 39.80815347721823},
            "radius" => 7
          }
        ],
        "date" => 3564,
        "factions" => [
          %{"key" => "myrmezir", "sector_number" => 1},
          %{"key" => "synelle", "sector_number" => 1}
        ],
        "game_mode_type" => "ranked",
        "mode" => "prod",
        "sectors" => [
          %{
            "area" => -425.5,
            "centroid" => [40.47160203681943, 53.52526439482961],
            "faction" => "synelle",
            "key" => 0,
            "name" => "Djarreh",
            "points" => [
              [44, 47],
              [40, 43],
              [27, 44],
              [27, 51],
              [33, 63],
              [46, 62],
              [54, 61],
              [58, 60],
              [51, 49],
              [44, 47]
            ],
            "points03" => [
              [27.3, 44.277809341778585],
              [27.3, 50.92917960675006],
              [33.17811643218991, 62.68541247112988],
              [45.969873265321674, 61.701431176273594],
              [53.94481394911896, 60.704563590798934],
              [57.523439066935616, 59.80990731134477],
              [50.8080568359625, 49.257163805529885],
              [43.917583661630786, 47.28845718429225],
              [43.855041684343874, 47.24635875357071],
              [43.78786796564403, 47.21213203435597],
              [39.885434896419035, 43.30969896513097],
              [27.3, 44.277809341778585]
            ],
            "systems" => [
              %{"key" => 1, "position" => %{"x" => 31, "y" => 53}, "type" => "orange_dwarf"},
              %{"key" => 2, "position" => %{"x" => 33, "y" => 50}, "type" => "red_dwarf"},
              %{"key" => 3, "position" => %{"x" => 33, "y" => 52}, "type" => "red_dwarf"},
              %{"key" => 4, "position" => %{"x" => 33, "y" => 54}, "type" => "orange_dwarf"},
              %{"key" => 5, "position" => %{"x" => 33, "y" => 55}, "type" => "red_dwarf"},
              %{"key" => 6, "position" => %{"x" => 33, "y" => 57}, "type" => "red_dwarf"},
              %{"key" => 7, "position" => %{"x" => 34, "y" => 55}, "type" => "red_dwarf"},
              %{"key" => 8, "position" => %{"x" => 34, "y" => 56}, "type" => "orange_dwarf"},
              %{"key" => 9, "position" => %{"x" => 34, "y" => 57}, "type" => "red_dwarf"},
              %{"key" => 10, "position" => %{"x" => 35, "y" => 51}, "type" => "orange_dwarf"},
              %{"key" => 11, "position" => %{"x" => 35, "y" => 52}, "type" => "red_dwarf"},
              %{"key" => 12, "position" => %{"x" => 35, "y" => 55}, "type" => "red_dwarf"},
              %{"key" => 13, "position" => %{"x" => 36, "y" => 49}, "type" => "yellow_dwarf"},
              %{"key" => 14, "position" => %{"x" => 36, "y" => 58}, "type" => "red_dwarf"},
              %{"key" => 15, "position" => %{"x" => 37, "y" => 54}, "type" => "orange_dwarf"},
              %{"key" => 16, "position" => %{"x" => 37, "y" => 56}, "type" => "orange_dwarf"},
              %{"key" => 17, "position" => %{"x" => 38, "y" => 48}, "type" => "red_dwarf"},
              %{"key" => 18, "position" => %{"x" => 38, "y" => 50}, "type" => "yellow_dwarf"},
              %{"key" => 19, "position" => %{"x" => 38, "y" => 52}, "type" => "orange_dwarf"},
              %{"key" => 20, "position" => %{"x" => 38, "y" => 57}, "type" => "red_dwarf"},
              %{"key" => 21, "position" => %{"x" => 38, "y" => 58}, "type" => "red_dwarf"},
              %{"key" => 22, "position" => %{"x" => 39, "y" => 50}, "type" => "orange_dwarf"},
              %{"key" => 23, "position" => %{"x" => 39, "y" => 55}, "type" => "red_dwarf"},
              %{"key" => 24, "position" => %{"x" => 40, "y" => 49}, "type" => "yellow_dwarf"},
              %{"key" => 25, "position" => %{"x" => 40, "y" => 55}, "type" => "orange_dwarf"},
              %{"key" => 26, "position" => %{"x" => 40, "y" => 57}, "type" => "red_dwarf"},
              %{"key" => 27, "position" => %{"x" => 40, "y" => 58}, "type" => "orange_dwarf"},
              %{"key" => 28, "position" => %{"x" => 41, "y" => 53}, "type" => "orange_dwarf"},
              %{"key" => 29, "position" => %{"x" => 41, "y" => 56}, "type" => "red_dwarf"},
              %{"key" => 30, "position" => %{"x" => 43, "y" => 49}, "type" => "orange_dwarf"},
              %{"key" => 31, "position" => %{"x" => 43, "y" => 56}, "type" => "red_dwarf"},
              %{"key" => 32, "position" => %{"x" => 44, "y" => 57}, "type" => "orange_dwarf"},
              %{"key" => 33, "position" => %{"x" => 45, "y" => 50}, "type" => "red_dwarf"},
              %{"key" => 34, "position" => %{"x" => 45, "y" => 54}, "type" => "orange_dwarf"},
              %{"key" => 35, "position" => %{"x" => 47, "y" => 53}, "type" => "red_dwarf"},
              %{"key" => 36, "position" => %{"x" => 47, "y" => 54}, "type" => "yellow_dwarf"},
              %{"key" => 37, "position" => %{"x" => 47, "y" => 55}, "type" => "red_dwarf"},
              %{"key" => 38, "position" => %{"x" => 48, "y" => 51}, "type" => "red_dwarf"},
              %{"key" => 39, "position" => %{"x" => 48, "y" => 54}, "type" => "orange_dwarf"},
              %{"key" => 40, "position" => %{"x" => 48, "y" => 55}, "type" => "red_dwarf"},
              %{"key" => 41, "position" => %{"x" => 49, "y" => 54}, "type" => "red_dwarf"}
            ],
            "victory_points" => 1
          },
          %{
            "area" => -179.5,
            "centroid" => [48.453110492107704, 40.200557103064064],
            "faction" => "synelle",
            "key" => 1,
            "name" => "Urnuzi",
            "points" => [
              [40, 43],
              [44, 47],
              [51, 49],
              [55, 41],
              [56, 35],
              [47, 31],
              [45, 34],
              [40, 43]
            ],
            "points03" => [
              [40.37214352756113, 42.947879458849194],
              [44.157163102839874, 46.73289903412794],
              [50.84301813837716, 48.64314332999574],
              [54.71149790854012, 40.906183789669825],
              [55.66589454875269, 35.179803948394394],
              [47.10930496464786, 31.376875244347808],
              [45.25635039046539, 34.15630710562151],
              [40.37214352756113, 42.947879458849194]
            ],
            "systems" => [
              %{"key" => 42, "position" => %{"x" => 48, "y" => 36}, "type" => "orange_dwarf"},
              %{"key" => 43, "position" => %{"x" => 50, "y" => 39}, "type" => "yellow_dwarf"},
              %{"key" => 44, "position" => %{"x" => 54, "y" => 39}, "type" => "orange_dwarf"},
              %{"key" => 45, "position" => %{"x" => 54, "y" => 40}, "type" => "red_dwarf"}
            ],
            "victory_points" => 1
          },
          %{
            "area" => -667.5,
            "centroid" => [44.783770287141074, 24.57478152309613],
            "faction" => "myrmezir",
            "key" => 2,
            "name" => "Asphalie",
            "points" => [
              [37, 31],
              [47, 31],
              [56, 35],
              [65, 35],
              [68, 30],
              [63, 20],
              [52, 18],
              [46, 15],
              [34, 11],
              [33, 17],
              [29, 19],
              [21, 22],
              [23, 31],
              [28, 31],
              [37, 31]
            ],
            "points03" => [
              [21.34940139672684, 22.18937461667684],
              [23.240651481909765, 30.7],
              [28, 30.7],
              [37, 30.7],
              [47, 30.7],
              [47.059557675309804, 30.71935146177],
              [47.12184153981603, 30.72585653541392],
              [56.0636643351347, 34.7],
              [64.83014288630928, 34.7],
              [67.6580230228906, 29.98686643903114],
              [62.79875388202502, 20.268328157299973],
              [51.94633436854001, 18.295160973029972],
              [51.90841942013441, 18.27474173959679],
              [51.86583592135001, 18.268328157299976],
              [45.884905416351216, 15.277862904800578],
              [34.23820015680094, 11.395627818283819],
              [33.295918177149645, 17.049319696191606],
              [33.2740379796858, 17.091418734136564],
              [33.266260353298236, 17.138222372507123],
              [33.23235808085493, 17.17161378929191],
              [33.21041344418955, 17.21383681279025],
              [33.167966798961274, 17.23503479254806],
              [33.13416407864999, 17.268328157299976],
              [29.134164078649988, 19.268328157299976],
              [29.118066944471305, 19.270752577503693],
              [29.105337032476516, 19.280898753270712],
              [21.34940139672684, 22.18937461667684]
            ],
            "systems" => [
              %{"key" => 46, "position" => %{"x" => 27, "y" => 27}, "type" => "red_dwarf"},
              %{"key" => 47, "position" => %{"x" => 29, "y" => 25}, "type" => "red_dwarf"},
              %{"key" => 48, "position" => %{"x" => 31, "y" => 23}, "type" => "orange_dwarf"},
              %{"key" => 49, "position" => %{"x" => 31, "y" => 25}, "type" => "red_dwarf"},
              %{"key" => 50, "position" => %{"x" => 31, "y" => 29}, "type" => "orange_dwarf"},
              %{"key" => 51, "position" => %{"x" => 31, "y" => 30}, "type" => "red_dwarf"},
              %{"key" => 52, "position" => %{"x" => 32, "y" => 30}, "type" => "yellow_dwarf"},
              %{"key" => 53, "position" => %{"x" => 34, "y" => 17}, "type" => "yellow_dwarf"},
              %{"key" => 54, "position" => %{"x" => 34, "y" => 25}, "type" => "yellow_dwarf"},
              %{"key" => 55, "position" => %{"x" => 34, "y" => 26}, "type" => "red_dwarf"},
              %{"key" => 56, "position" => %{"x" => 34, "y" => 28}, "type" => "red_dwarf"},
              %{"key" => 57, "position" => %{"x" => 34, "y" => 30}, "type" => "yellow_dwarf"},
              %{"key" => 58, "position" => %{"x" => 35, "y" => 16}, "type" => "orange_dwarf"},
              %{"key" => 59, "position" => %{"x" => 35, "y" => 17}, "type" => "orange_dwarf"},
              %{"key" => 60, "position" => %{"x" => 35, "y" => 22}, "type" => "yellow_dwarf"},
              %{"key" => 61, "position" => %{"x" => 36, "y" => 20}, "type" => "white_dwarf"},
              %{"key" => 62, "position" => %{"x" => 36, "y" => 24}, "type" => "orange_dwarf"},
              %{"key" => 63, "position" => %{"x" => 36, "y" => 27}, "type" => "orange_dwarf"},
              %{"key" => 64, "position" => %{"x" => 37, "y" => 20}, "type" => "orange_dwarf"},
              %{"key" => 65, "position" => %{"x" => 37, "y" => 25}, "type" => "red_dwarf"},
              %{"key" => 66, "position" => %{"x" => 37, "y" => 27}, "type" => "orange_dwarf"},
              %{"key" => 67, "position" => %{"x" => 38, "y" => 16}, "type" => "red_dwarf"},
              %{"key" => 68, "position" => %{"x" => 38, "y" => 22}, "type" => "yellow_dwarf"},
              %{"key" => 69, "position" => %{"x" => 38, "y" => 26}, "type" => "white_dwarf"},
              %{"key" => 70, "position" => %{"x" => 38, "y" => 30}, "type" => "red_dwarf"},
              %{"key" => 71, "position" => %{"x" => 39, "y" => 14}, "type" => "red_dwarf"},
              %{"key" => 72, "position" => %{"x" => 39, "y" => 16}, "type" => "yellow_dwarf"},
              %{"key" => 73, "position" => %{"x" => 39, "y" => 22}, "type" => "yellow_dwarf"},
              %{"key" => 74, "position" => %{"x" => 39, "y" => 27}, "type" => "yellow_dwarf"},
              %{"key" => 75, "position" => %{"x" => 39, "y" => 28}, "type" => "red_dwarf"},
              %{"key" => 76, "position" => %{"x" => 39, "y" => 29}, "type" => "yellow_dwarf"},
              %{"key" => 77, "position" => %{"x" => 40, "y" => 23}, "type" => "orange_dwarf"},
              %{"key" => 78, "position" => %{"x" => 41, "y" => 16}, "type" => "orange_dwarf"},
              %{"key" => 79, "position" => %{"x" => 41, "y" => 17}, "type" => "orange_dwarf"},
              %{"key" => 80, "position" => %{"x" => 41, "y" => 20}, "type" => "red_dwarf"},
              %{"key" => 81, "position" => %{"x" => 41, "y" => 27}, "type" => "orange_dwarf"},
              %{"key" => 82, "position" => %{"x" => 42, "y" => 25}, "type" => "red_dwarf"},
              %{"key" => 83, "position" => %{"x" => 42, "y" => 29}, "type" => "orange_dwarf"},
              %{"key" => 84, "position" => %{"x" => 43, "y" => 19}, "type" => "red_dwarf"},
              %{"key" => 85, "position" => %{"x" => 44, "y" => 19}, "type" => "orange_dwarf"},
              %{"key" => 86, "position" => %{"x" => 45, "y" => 18}, "type" => "yellow_dwarf"},
              %{"key" => 87, "position" => %{"x" => 45, "y" => 21}, "type" => "orange_dwarf"},
              %{"key" => 88, "position" => %{"x" => 45, "y" => 23}, "type" => "orange_dwarf"},
              %{"key" => 89, "position" => %{"x" => 45, "y" => 24}, "type" => "orange_dwarf"},
              %{"key" => 90, "position" => %{"x" => 46, "y" => 17}, "type" => "red_dwarf"},
              %{"key" => 91, "position" => %{"x" => 46, "y" => 18}, "type" => "red_giant"},
              %{"key" => 92, "position" => %{"x" => 47, "y" => 20}, "type" => "orange_dwarf"},
              %{"key" => 93, "position" => %{"x" => 50, "y" => 28}, "type" => "red_dwarf"},
              %{"key" => 94, "position" => %{"x" => 51, "y" => 26}, "type" => "orange_dwarf"},
              %{"key" => 95, "position" => %{"x" => 53, "y" => 31}, "type" => "red_dwarf"},
              %{"key" => 96, "position" => %{"x" => 54, "y" => 31}, "type" => "red_dwarf"},
              %{"key" => 97, "position" => %{"x" => 55, "y" => 31}, "type" => "red_dwarf"},
              %{"key" => 98, "position" => %{"x" => 56, "y" => 22}, "type" => "red_dwarf"},
              %{"key" => 99, "position" => %{"x" => 56, "y" => 23}, "type" => "orange_dwarf"},
              %{"key" => 100, "position" => %{"x" => 56, "y" => 26}, "type" => "orange_dwarf"},
              %{"key" => 101, "position" => %{"x" => 56, "y" => 33}, "type" => "orange_dwarf"},
              %{"key" => 102, "position" => %{"x" => 57, "y" => 28}, "type" => "white_dwarf"},
              %{"key" => 103, "position" => %{"x" => 57, "y" => 30}, "type" => "orange_dwarf"},
              %{"key" => 104, "position" => %{"x" => 57, "y" => 33}, "type" => "white_dwarf"},
              %{"key" => 105, "position" => %{"x" => 58, "y" => 24}, "type" => "orange_dwarf"},
              %{"key" => 106, "position" => %{"x" => 58, "y" => 25}, "type" => "orange_dwarf"},
              %{"key" => 107, "position" => %{"x" => 59, "y" => 22}, "type" => "orange_dwarf"},
              %{"key" => 108, "position" => %{"x" => 59, "y" => 29}, "type" => "red_dwarf"},
              %{"key" => 109, "position" => %{"x" => 59, "y" => 32}, "type" => "orange_dwarf"},
              %{"key" => 110, "position" => %{"x" => 60, "y" => 25}, "type" => "orange_dwarf"},
              %{"key" => 111, "position" => %{"x" => 60, "y" => 27}, "type" => "orange_dwarf"},
              %{"key" => 112, "position" => %{"x" => 60, "y" => 28}, "type" => "red_dwarf"},
              %{"key" => 113, "position" => %{"x" => 60, "y" => 31}, "type" => "orange_dwarf"},
              %{"key" => 114, "position" => %{"x" => 61, "y" => 23}, "type" => "orange_dwarf"},
              %{"key" => 115, "position" => %{"x" => 62, "y" => 24}, "type" => "red_dwarf"},
              %{"key" => 116, "position" => %{"x" => 62, "y" => 26}, "type" => "red_dwarf"},
              %{"key" => 117, "position" => %{"x" => 62, "y" => 30}, "type" => "orange_dwarf"},
              %{"key" => 118, "position" => %{"x" => 63, "y" => 26}, "type" => "orange_dwarf"},
              %{"key" => 119, "position" => %{"x" => 64, "y" => 29}, "type" => "red_dwarf"}
            ],
            "victory_points" => 1
          }
        ],
        "seed" => [845, 427, 543],
        "size" => 80,
        "speed" => "fast",
        "time_limit" => 200
      },
      id: instance_id
    }
  end
end
