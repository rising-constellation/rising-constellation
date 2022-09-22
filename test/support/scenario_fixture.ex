defmodule RC.ScenarioFixtures do
  alias RC.Scenarios
  alias RC.Instances

  @filename "test.png"
  @file_path File.cwd!() <> "/test/support/" <> @filename

  @image_plug_upload %Plug.Upload{
    content_type: "image/png",
    filename: @filename,
    path: @file_path
  }

  @map_create_attrs %{
    game_data: %{},
    game_metadata: %{},
    is_map: true,
    is_official: true,
    thumbnail: @image_plug_upload
  }

  @scenario_create_attrs %{
    game_data: %{
      "data" => "some data"
    },
    game_metadata: %{
      "data" => "some data"
    }
  }

  @instance_valid_attrs %{
    "description" => "some description",
    "name" => "some name",
    "opening_date" => "2010-04-17T14:00:00Z",
    "registration_type" => "pre_registration",
    "registration_status" => "open",
    "game_type" => "official",
    "public" => true,
    "start_setting" => "auto",
    "factions" => [%{"key" => "tetrarchy", "capacity" => 10}, %{"key" => "myrmezir", "capacity" => 10}]
  }

  @owner_account_attrs %{
    "email" => "owner@admin",
    "hashed_password" => "some admin hashed_password",
    "password" => "some admin password",
    "name" => "some owner name",
    "role" => "admin",
    "status" => "registered"
  }

  # def get_instance_owner_account() do
  #   {:ok, account} = RC.Accounts.get_account_by_email(@owner_account_attrs["email"])
  #   account
  # end

  def map_fixture(attrs \\ %{}) do
    {:ok, %{map_with_thumbnail: map}} =
      attrs
      |> Enum.into(@map_create_attrs)
      |> Scenarios.create_map()

    map
  end

  def scenario_fixture(attrs \\ %{}) do
    {:ok, %{map_with_thumbnail: map}} =
      attrs
      |> Enum.into(@map_create_attrs)
      |> Scenarios.create_map()

    # Don't know what to put in the data and metadata so I put the same values
    {:ok, scenario} =
      Scenarios.create_scenario(
        %{
          game_data: Map.merge(map.game_data, @scenario_create_attrs.game_data),
          game_metadata: Map.merge(map.game_data, @scenario_create_attrs.game_data),
          is_official: map.is_official,
          is_map: false,
          thumbnail: map.thumbnail
        },
        :reuse_thumbnail
      )

    scenario
  end

  def valid_scenario_fixture(attrs \\ %{}) do
    {:ok, %{map_with_thumbnail: map}} =
      attrs
      |> Enum.into(@map_create_attrs)
      |> Scenarios.create_map()

    game_data =
      File.read!("test/support/scenario_game_data.json")
      |> Jason.decode!()

    game_metadata =
      File.read!("test/support/scenario_game_metadata.json")
      |> Jason.decode!()

    # Don't know what to put in the data and metadata so I put the same values
    {:ok, scenario} =
      Scenarios.create_scenario(
        %{
          game_data: game_data,
          game_metadata: game_metadata,
          is_official: map.is_official,
          is_map: false,
          thumbnail: map.thumbnail
        },
        :reuse_thumbnail
      )

    scenario
  end

  def instance_fixture(registration_type \\ :pre) do
    scenario = scenario_fixture()

    {:ok, account} =
      case RC.Fixtures.create_account(@owner_account_attrs) do
        {:ok, account} -> {:ok, account}
        _ -> RC.Accounts.get_account_by_email(@owner_account_attrs["email"])
      end

    instance_params =
      %{}
      |> Enum.into(@instance_valid_attrs)
      |> Map.put("registration_type", if(registration_type == :late, do: "late_registration", else: "pre_registration"))

    {:ok, %{instance: instance}} = Instances.create_instance(instance_params, scenario, account.id)

    instance =
      instance
      |> Map.put(:state, "created")
      |> Map.put(
        :factions,
        Enum.map(Map.get(instance, :factions), fn f ->
          Map.put(f, :registrations_count, 0)
        end)
      )

    %{instance: instance, account: account}
  end

  def valid_instance_fixture(late \\ false) do
    scenario = valid_scenario_fixture()

    {:ok, account} =
      case RC.Fixtures.create_account(@owner_account_attrs) do
        {:ok, account} -> {:ok, account}
        _ -> RC.Accounts.get_account_by_email(@owner_account_attrs["email"])
      end

    instance_attrs = @instance_valid_attrs

    instance_attrs =
      if late == true,
        do: Map.put(instance_attrs, "registration_type", "late_registration"),
        else: instance_attrs

    {:ok, %{instance: instance}} = Instances.create_instance(instance_attrs, scenario, account.id)
    instance = Instances.get_instance_with_registration(instance.id)

    %{instance: instance, account: account}
  end
end
