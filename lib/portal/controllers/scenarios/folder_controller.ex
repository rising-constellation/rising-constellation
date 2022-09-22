defmodule Portal.FolderController do
  @moduledoc """
  The Folder controller.

  API:

  Create a Folder and insert Scenarios and Maps:
      POST /folders, body: %{folder: folders_params, scenario_or_map_ids: [...]}
  Update a Folder:
      PUT /folders/:fid, body: %{folder: update_params}
  Delete a Folder:
      DELETE /folders/:fid
  List the Folders:
      GET /folders
  Get a single Folder:
      GET /folders/:fid

  Like a Scenario:
      POST /scenarios/:sid/folders/likes
  Disike a Scenario:
      POST /scenarios/:sid/folders/dislikes
  Favorite a Scenario:
      POST /scenarios/:sid/folders/favorites
  Insert a Scenario into a folder:
      PUT /scenarios/:sid/folders/:fid
  Remove a Scenario from a folder:
      DELETE /scenarios/:sid/folders/:fid

  Like a Map:
      POST /maps/:mid/folders/likes
  Disike a Map:
      POST /maps/:mid/folders/dislikes
  Favorite a Map:
      POST /maps/:mid/folders/favorites
  Insert a Map into a folder:
      PUT /maps/:mid/folders/:fid
  Remove a Map from a folder:
      DELETE /maps/:mid/folders/:fid
  """
  use Portal, :controller

  alias RC.Scenarios
  alias RC.Scenarios.Folder

  require Logger

  action_fallback(Portal.FallbackController)

  def index(conn, _params) do
    folders = Scenarios.list_folders()

    conn
    |> Scrivener.Headers.paginate(folders)
    |> render("index.json", folders: folders)
  end

  def create(conn, %{"folder" => folder_params, "scenario_or_map_ids" => scenario_or_map_ids}) do
    account_id = conn.private.guardian_default_resource.id

    with {:ok, %Folder{} = folder} <- Scenarios.create_folder(folder_params, account_id),
         {:ok, _} <- Scenarios.insert_map_or_scenario(folder, scenario_or_map_ids) do
      conn
      |> put_status(:created)
      |> render("show.json", folder: Scenarios.get_folder(folder.id))
    else
      error ->
        error
    end
  end

  def insert(conn, %{"fid" => fid, "sid" => sid}) do
    insert(conn, fid, sid)
  end

  def remove(conn, %{"fid" => fid, "sid" => sid}) do
    remove(conn, fid, sid)
  end

  def like(conn, %{"sid" => sid}) do
    add_to_special_folder(conn, sid, :like)
  end

  def dislike(conn, %{"sid" => sid}) do
    add_to_special_folder(conn, sid, :dislike)
  end

  def favorite(conn, %{"sid" => sid}) do
    add_to_special_folder(conn, sid, :favorite)
  end

  def show(conn, %{"fid" => id}) do
    folder = Scenarios.get_folder(id)
    render(conn, "show.json", folder: folder)
  end

  def update(conn, %{"fid" => id, "folder" => folder_params}) do
    folder = Scenarios.get_folder(id)

    case Scenarios.update_folder(folder, folder_params) do
      {:ok, %Folder{} = folder} -> render(conn, "show.json", folder: folder)
      error -> error
    end
  end

  def delete(conn, %{"fid" => id}) do
    folder = Scenarios.get_folder(id)

    case Scenarios.delete_folder(folder) do
      {:ok, %Folder{}} -> send_resp(conn, :no_content, "")
      error -> error
    end
  end

  defp remove(conn, folder_id, map_or_scenario_id, type \\ :scenario) do
    with folder when not is_nil(folder) <- Scenarios.get_folder(folder_id),
         {1, nil} <- Scenarios.remove_map_or_scenario(folder, map_or_scenario_id) do
      send_resp(conn, :no_content, "")
    else
      nil ->
        {:error, :not_found}

      {0, _} ->
        message =
          if type == :map,
            do: :map_not_found,
            else: :scenario_not_found

        conn
        |> put_status(404)
        |> json(%{message: message})
    end
  end

  defp insert(conn, folder_id, map_or_scenario_id, type \\ :scenario) do
    with folder when not is_nil(folder) <- Scenarios.get_folder(folder_id),
         {:ok, _} <- Scenarios.insert_map_or_scenario(folder, [map_or_scenario_id]) do
      message =
        if type == :map,
          do: :map_inserted,
          else: :scenario_inserted

      conn
      |> put_status(200)
      |> json(%{message: message})
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  defp add_to_special_folder(conn, map_or_scenario_id, special_folder_atom) do
    {folder_atom, message_atom} =
      case special_folder_atom do
        :like ->
          {:scenario_likes_name, :liked}

        :dislike ->
          {:scenario_dislikes_name, :disliked}

        :favorite ->
          {:scenario_favorites_name, :added_to_favorites}
      end

    account_id = conn.private.guardian_default_resource.id
    folder_name = Application.get_env(:rc, RC.Scenarios.Folder) |> Keyword.get(folder_atom)

    :ok =
      if special_folder_atom in [:like, :dislike] do
        case Scenarios.get_opposite_folder(account_id, map_or_scenario_id, special_folder_atom) do
          nil ->
            :ok

          opposite_folder ->
            {1, _scenario_folder} = Scenarios.remove_map_or_scenario(opposite_folder, map_or_scenario_id)
            :ok
        end
      end

    {:ok, folder} =
      case Scenarios.get_folder(account_id, folder_atom) do
        nil ->
          Scenarios.create_reserved_folder(
            %{
              name: folder_name,
              description: "likes"
            },
            account_id
          )

        folder ->
          {:ok, folder}
      end

    case Scenarios.insert_map_or_scenario(folder, [map_or_scenario_id]) do
      {:ok, _} ->
        conn
        |> put_status(200)
        |> json(%{message: message_atom})

      error ->
        error
    end
  end
end
