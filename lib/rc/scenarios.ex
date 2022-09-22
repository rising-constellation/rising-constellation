defmodule RC.Scenarios do
  @moduledoc """
  The Scenarios context.
  """
  import Ecto.Query, warn: false

  alias RC.Repo
  alias RC.Scenarios.Scenario
  alias RC.Scenarios.Folder
  alias RC.Scenarios.ScenarioFolder
  alias Ecto.Multi

  @likes_name Application.compile_env(:rc, RC.Scenarios.Folder) |> Keyword.get(:scenario_likes_name)
  @dislikes_name Application.compile_env(:rc, RC.Scenarios.Folder) |> Keyword.get(:scenario_dislikes_name)
  @favorites_name Application.compile_env(:rc, RC.Scenarios.Folder) |> Keyword.get(:scenario_favorites_name)

  defp list_maps_query() do
    from(m in RC.Scenarios.Map,
      left_join: f in assoc(m, :folders),
      group_by: m.id,
      where: m.is_map == true,
      select_merge: %{
        likes: fragment("COUNT(CASE WHEN ? = ? THEN ? ELSE NULL END)", f.name, ^@likes_name, f.id),
        dislikes: fragment("COUNT(CASE WHEN ? = ? THEN ? ELSE NULL END)", f.name, ^@dislikes_name, f.id),
        favorites: fragment("COUNT(CASE WHEN ? = ? THEN ? ELSE NULL END)", f.name, ^@favorites_name, f.id)
      }
    )
  end

  @doc """
  Returns the list of maps.

  ## Examples

      iex> list_maps()
      [%RC.Scenarios.Map{}, ...]

  """
  def list_maps do
    Repo.paginate(list_maps_query())
  end

  @doc """
  Returns the list of maps with filtered fields.
  Filters should be provided with a map structure.

  ## Examples

      iex> list_maps(filters)
      [%RC.Scenarios.Map{}, ...]

  """
  def list_maps(filters) when is_map(filters) do
    query =
      list_maps_query()
      |> put_map_filters(filters)

    Repo.paginate(query)
  end

  @doc """
  Gets a single map.

  Returns `nil` if the RC.Scenarios.Map does not exist.

  ## Examples

      iex> get_map(123)
      %RC.Scenarios.Map{}

      iex> get_map!(456)
      nil

  """
  def get_map(id) do
    Repo.one(
      from(m in RC.Scenarios.Map,
        left_join: f in assoc(m, :folders),
        group_by: m.id,
        where: m.id == ^id and m.is_map == true,
        select_merge: %{
          likes: fragment("COUNT(CASE WHEN ? = ? THEN ? ELSE NULL END)", f.name, @likes_name, f.id),
          dislikes: fragment("COUNT(CASE WHEN ? = ? THEN ? ELSE NULL END)", f.name, @dislikes_name, f.id),
          favorites: fragment("COUNT(CASE WHEN ? = ? THEN ? ELSE NULL END)", f.name, @favorites_name, f.id)
        }
      )
    )
  end

  @doc """
  Gets a single map as a Scenario structure.
  This function is used to delete a map since Scenario and Map shares the same table.

  Returns `nil` if the RC.Scenarios.Map does not exist.

  ## Examples

      iex> get_map(123)
      %RC.Scenarios.Map{}

      iex> get_map!(456)
      nil

  """
  def get_map_as_scenario(id) do
    Repo.one(
      from(s in Scenario,
        where: s.id == ^id and s.is_map == true
      )
    )
  end

  @doc """
  Creates a map.

  ## Examples

      iex> create_map(%{field: value})
      {:ok, %RC.Scenarios.Map{}}

      iex> create_map(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_map(attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:map, RC.Scenarios.Map.changeset(%RC.Scenarios.Map{}, attrs))
    |> Ecto.Multi.update(:map_with_thumbnail, &RC.Scenarios.Map.thumbnail_changeset(&1.map, attrs))
    |> Repo.transaction()
  end

  @doc """
  Creates a map.

  ## Examples

      iex> create_map(%{field: value})
      {:ok, %RC.Scenarios.Map{}}

      iex> create_map(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_map(attrs, :no_thumbnail) do
    %RC.Scenarios.Map{}
    |> RC.Scenarios.Map.changeset_no_thumbnail(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a map.

  ## Examples

      iex> update_map(map, %{field: new_value})
      {:ok, %RC.Scenarios.Map{}}

      iex> update_map(map, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_map(%RC.Scenarios.Map{} = map, attrs) do
    map
    |> RC.Scenarios.Map.changeset(attrs)
    |> Repo.update()
  end

  defp list_scenarios_query() do
    from(s in RC.Scenarios.Scenario,
      left_join: f in assoc(s, :folders),
      group_by: s.id,
      where: s.is_map == false,
      select_merge: %{
        likes: fragment("COUNT(CASE WHEN ? = ? THEN ? ELSE NULL END)", f.name, ^@likes_name, f.id),
        dislikes: fragment("COUNT(CASE WHEN ? = ? THEN ? ELSE NULL END)", f.name, ^@dislikes_name, f.id),
        favorites: fragment("COUNT(CASE WHEN ? = ? THEN ? ELSE NULL END)", f.name, ^@favorites_name, f.id)
      }
    )
  end

  @doc """
  Returns the list of scenarios.

  ## Examples

      iex> list_scenarios()
      [%Scenario{}, ...]

  """

  def list_scenarios do
    Repo.paginate(list_scenarios_query())
  end

  @doc """
  Returns the filtered list of scenarios.
  The filters should be provided in a map structure.

  ## Examples

      iex> list_scenarios()
      [%Scenario{}, ...]

  """
  def list_scenarios(filters) when is_map(filters) do
    query =
      list_scenarios_query()
      |> put_scenario_filters(filters)

    Repo.paginate(query)
  end

  @doc """
  List scenario in reserved folder.
  `folder_atom` is either `:scenario_likes_name`, `scenario_dislikes_name` or `scenario_favorites_name`


  ## Examples

      iex> list_scenarios(1, :scenario_likes_name)
      [%Scenario{}, ...]

  """
  def list_scenarios(account_id, folder_atom) do
    folder_name = Application.get_env(:rc, RC.Scenarios.Folder) |> Keyword.get(folder_atom)

    Repo.paginate(
      from(s in Scenario,
        join: f in assoc(s, :folders),
        where: f.name == ^folder_name and f.account_id == ^account_id
      )
    )
  end

  @doc """
  Gets a single scenario.

  Returns nil` if the scenario does not exist.

  ## Examples

      iex> get_scenario(123)
      %scenario{}

      iex> get_scenario!(456)
      nil

  """
  def get_scenario(id) do
    Repo.one(
      from(s in Scenario,
        left_join: f in assoc(s, :folders),
        group_by: s.id,
        where: s.id == ^id and s.is_map == false,
        select_merge: %{
          likes: fragment("COUNT(CASE WHEN ? = ? THEN ? ELSE NULL END)", f.name, @likes_name, f.id),
          dislikes: fragment("COUNT(CASE WHEN ? = ? THEN ? ELSE NULL END)", f.name, @dislikes_name, f.id),
          favorites: fragment("COUNT(CASE WHEN ? = ? THEN ? ELSE NULL END)", f.name, @favorites_name, f.id)
        }
      )
    )
  end

  @doc """
  Creates a scenario with either:
  - a thumbnail to upload
  - using an already uploaded image as thumbail
  - no thumbnail

  ## Examples

      iex> create_scenario(%{field: value, thumbnail: %Plug.Upload{...}}, :create_thumbnail)
      {:ok, %Scenario{}}

      iex> create_scenario(%{field: bad_value}, :create_thumbnail)
      {:error, %Ecto.Changeset{}}

      iex> create_scenario(%{field: value}, :reuse_thumbnail)
      {:ok, %Scenario{}}

      iex> create_scenario(%{field: bad_value}, :reuse_thumbnail)
      {:error, %Ecto.Changeset{}}

      iex> create_scenario(%{field: value}, :no_thumbnail)
      {:ok, %Scenario{}}

      iex> create_scenario(%{field: bad_value}, :no_thumbnail)
      {:error, %Ecto.Changeset{}}
  """
  def create_scenario(scenario_attrs, :create_thumbnail) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:scenario, RC.Scenarios.Scenario.changeset(%RC.Scenarios.Scenario{}, scenario_attrs))
    |> Ecto.Multi.update(
      :scenario_with_thumbnail,
      &RC.Scenarios.Scenario.thumbnail_changeset(&1.scenario, scenario_attrs)
    )
    |> Repo.transaction()
  end

  def create_scenario(scenario_attrs, :reuse_thumbnail) do
    %Scenario{}
    |> Scenario.changeset_reuse_thumbnail(scenario_attrs)
    |> Repo.insert()
  end

  def create_scenario(scenario_attrs, :no_thumbnail) do
    %Scenario{}
    |> Scenario.changeset_no_thumbnail(scenario_attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a scenario.

  ## Examples

      iex> update_scenario(scenario, %{field: new_value})
      {:ok, %scenario{}}

      iex> update_scenario(scenario, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_scenario(%Scenario{} = scenario, attrs) do
    scenario
    |> Scenario.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a scenario.

  ## Examples

      iex> delete_scenario(scenario)
      {:ok, %Scenario{}}

      iex> delete_scenario(scenario)
      {:error, %Ecto.Changeset{}}

  """
  def delete_scenario(%Scenario{} = scenario) do
    Repo.delete(scenario)
  end

  @doc """
  Returns the count of Map and Scenario in a special folder.
  The parameter `folder_atom` should be either `:scenario_likes_name`, `scenario_dislikes_name` or `scenario_favorites_name`.
  """
  def get_reserved_folder_count(scenario_id, folder_atom) do
    reserved_name = Application.get_env(:rc, RC.Scenarios.Folder) |> Keyword.get(folder_atom)

    query =
      from(sf in ScenarioFolder,
        join: f in Folder,
        on: sf.folder_id == f.id,
        where: sf.scenario_id == ^scenario_id and f.name == ^reserved_name
      )

    Repo.aggregate(query, :count)
  end

  @doc """
  Returns `true` if a special folder exists.
  The parameter `folder_atom` should be either `:scenario_likes_name`, `scenario_dislikes_name` or `scenario_favorites_name`.
  """
  def folder_exists?(account_id, folder_atom) do
    folder_name = Application.get_env(:rc, RC.Scenarios.Folder) |> Keyword.get(folder_atom)

    Repo.exists?(
      from(f in Folder,
        where: f.name == ^folder_name and f.account_id == ^account_id
      )
    )
  end

  @doc """
  Returns the list of folders.

  ## Examples

      iex> list_folders()
      [%Folder{}, ...]

  """
  def list_folders do
    Repo.paginate(Folder)
  end

  @doc """
  Gets a single folder.

  Raises `Ecto.NoResultsError` if the Folder does not exist.

  ## Examples

      iex> get_folder(123)
      %Folder{}

      iex> get_folder(456)
      ** (Ecto.NoResultsError)

  """
  def get_folder(id), do: Repo.get(Folder, id)

  @doc """
  Gets a single reserved folder given an account_id.
  The parameter `folder_atom` should be either `:scenario_likes_name`, `scenario_dislikes_name` or `scenario_favorites_name`.

  Returns `nil` if the folder does not exist.
  """
  def get_folder(account_id, folder_atom) do
    folder_name = Application.get_env(:rc, RC.Scenarios.Folder) |> Keyword.get(folder_atom)

    Repo.one(
      from(f in Folder,
        where: f.name == ^folder_name and f.account_id == ^account_id
      )
    )
  end

  @doc """
  Gets a like or dislike folder.
  If the atom is `:like` it looks for the `:dislike` folder and vice versa.
  Returns `nil` if the folders does not exist.


  ## Examples

      iex> get_opposite_folder(account_id, :like)
      {:ok, %Folder{}}

      iex> get_opposite_folder(account_id, :like)
      nil

  """
  def get_opposite_folder(account_id, scenario_id, folder_atom) do
    folder_name =
      if folder_atom == :like,
        do: @dislikes_name,
        else: @likes_name

    Repo.one(
      from(f in Folder,
        join: s in assoc(f, :scenarios),
        where: f.account_id == ^account_id and f.name == ^folder_name and s.id == ^scenario_id
      )
    )
  end

  @doc """
  Creates a folder.

  ## Examples

      iex> create_folder(%{field: value})
      {:ok, %Folder{}}

      iex> create_folder(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_folder(attrs) do
    %Folder{}
    |> Folder.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a folder with an account reference.

  ## Examples

      iex> create_folder(%{field: value}, 123)
      {:ok, %Folder{}}

  """
  def create_folder(attrs, account_id) do
    %Folder{}
    |> Map.put(:account_id, account_id)
    |> Folder.changeset_not_reserved(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a reserved folder with an account reference.
  The parameter `folder_atom` should be either `:scenario_likes_name`, `scenario_dislikes_name` or `scenario_favorites_name`.

  """
  def create_reserved_folder(attrs, account_id) do
    %Folder{}
    |> Map.put(:account_id, account_id)
    |> Folder.changeset_reserved(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a folder.

  ## Examples

      iex> update_folder(folder, %{field: new_value})
      {:ok, %Folder{}}

      iex> update_folder(folder, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_folder(%Folder{} = folder, attrs) do
    folder
    |> Folder.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a folder.

  ## Examples

      iex> delete_folder(folder)
      {:ok, %Folder{}}

      iex> delete_folder(folder)
      {:error, %Ecto.Changeset{}}

  """
  def delete_folder(%Folder{} = folder) do
    Repo.delete(folder)
  end

  @doc """
  Inserts a Map or Scenario in a Folder, `scenario_ids` is a list of ids.
  Map and Scenario shares the same table so the two structures can be inserted at the same time.
  """
  def insert_map_or_scenario(folder, scenario_ids) do
    {trx, _} =
      Enum.reduce(scenario_ids, {Multi.new(), 0}, fn sid, {trx_acc, idx_acc} ->
        folder_params = %{folder_id: folder.id, scenario_id: sid}

        {trx_acc
         |> Multi.insert(
           "scenario_folders_#{idx_acc}",
           ScenarioFolder.changeset(%ScenarioFolder{}, folder_params)
         ), idx_acc + 1}
      end)

    Repo.transaction(trx)
  end

  @doc """
  Removes a Map or Scenario from a Folder.
  """
  def remove_map_or_scenario(folder, scenario_id) do
    Repo.delete_all(
      from(sf in ScenarioFolder,
        where: sf.scenario_id == ^scenario_id and sf.folder_id == ^folder.id
      )
    )
  end

  # Converts and put the filters in the `filters` map into the query on the jsonb field `game_metadata`.
  defp put_map_filters(query, filters) when is_map(filters) do
    Enum.reduce(filters, query, fn {key, val}, query_acc ->
      case key do
        "id" ->
          where(query_acc, [m], m.id == ^val)

        "is_official" ->
          where(query_acc, [m], m.is_official == ^val)

        "size" ->
          where(query_acc, fragment("game_metadata @> ?", ^%{size: String.to_integer(val)}))

        "name" ->
          pattern = "%" <> val <> "%"
          where(query_acc, [m], fragment("game_metadata->>'name' like ?", ^pattern))

        _ ->
          query_acc
      end
    end)
  end

  # Converts and put the filters in the `filters` map into the query on the jsonb field `game_metadata`.
  defp put_scenario_filters(query, filters) when is_map(filters) do
    Enum.reduce(filters, query, fn {key, val}, query_acc ->
      case key do
        "id" ->
          where(query_acc, [m], m.id == ^val)

        "is_official" ->
          where(query_acc, [m], m.is_official == ^val)

        "size" ->
          where(query_acc, fragment("game_metadata @> ?", ^%{size: String.to_integer(val)}))

        "speed" ->
          where(query_acc, fragment("game_metadata @> ?", ^%{speed: val}))

        "mode" ->
          where(query_acc, fragment("game_metadata @> ?", ^%{mode: val}))

        "name" ->
          pattern = "%" <> val <> "%"
          where(query_acc, [m], fragment("game_metadata->>'name' like ?", ^pattern))

        _ ->
          query_acc
      end
    end)
  end
end
