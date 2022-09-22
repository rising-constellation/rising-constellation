defmodule Portal.GroupController do
  use Portal, :controller

  alias RC.Groups
  alias RC.Groups.Group

  require Logger

  action_fallback(Portal.FallbackController)

  def index(conn, _params) do
    groups = Groups.list_groups()
    render(conn, "index.json", groups: groups)
  end

  def create(conn, %{"group" => group_params, "account_ids" => account_ids}) do
    with {:ok, %Group{} = group} <- Groups.create_group(group_params),
         {:ok, _} <- Groups.insert_accounts(group, account_ids) do
      conn
      |> put_status(:created)
      |> render("show.json", group: Groups.get_group(group.id))
    else
      {:error, failed_operation, %{errors: [unique: _]} = failed_value, _changes_so_far} ->
        Logger.info("#{inspect(failed_operation)}, failed value: #{inspect(failed_value)}")

        conn
        |> put_status(409)
        |> json(%{message: RC.Repo.format_errors(failed_value)})

      error ->
        error
    end
  end

  def add_instances(conn, %{"gid" => group_id, "instance_ids" => instance_ids}) do
    case Groups.get_group(group_id) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{message: :group_not_found})

      group ->
        case Groups.insert_instances(group, instance_ids) do
          {:ok, _group_with_instances} ->
            conn
            |> put_status(:created)
            |> render("show.json", group: Groups.get_group(group.id))

          {:error, failed_operation, %{errors: [unique: _]} = failed_value, _changes_so_far} ->
            Logger.info("#{inspect(failed_operation)}, failed value: #{inspect(failed_value)}")

            conn
            |> put_status(409)
            |> json(%{message: RC.Repo.format_errors(failed_value)})

          error ->
            error
        end
    end
  end

  def add_accounts(conn, %{"gid" => group_id, "account_ids" => account_ids}) do
    case Groups.get_group(group_id) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{message: :group_not_found})

      group ->
        case Groups.insert_accounts(group, account_ids) do
          {:ok, _group_with_accounts} ->
            conn
            |> put_status(:created)
            |> render("show.json", group: Groups.get_group(group.id))

          {:error, failed_operation, %{errors: [unique: _]} = failed_value, _changes_so_far} ->
            Logger.info("#{inspect(failed_operation)}, failed value: #{inspect(failed_value)}")

            conn
            |> put_status(409)
            |> json(%{message: RC.Repo.format_errors(failed_value)})

          error ->
            error
        end
    end
  end

  def show(conn, %{"gid" => gid}) do
    case Groups.get_group(gid) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{message: :group_not_found})

      group ->
        render(conn, "show.json", group: group)
    end
  end

  def update(conn, %{"gid" => gid, "group" => group_params}) do
    case Groups.get_group(gid) do
      nil ->
        {:error, :not_found}

      group ->
        case Groups.update_group(group, group_params) do
          {:ok, %Group{} = group} -> render(conn, "show.json", group: group)
          error -> error
        end
    end
  end

  def delete(conn, %{"gid" => id}) do
    case Groups.get_group(id) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{message: :group_not_found})

      group ->
        with {:ok, %Group{}} <- Groups.delete_group(group) do
          send_resp(conn, :no_content, "")
        end
    end
  end

  def remove_account(conn, %{"gid" => gid, "aid" => aid}) do
    case Groups.get_group(gid) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{message: :group_not_found})

      group ->
        case Groups.remove_account(group, aid) do
          {1, nil} ->
            send_resp(conn, :no_content, "")

          {:error, _reason} ->
            conn
            |> put_status(404)
            |> json(%{message: :account_not_found})
        end
    end
  end

  def remove_instance(conn, %{"gid" => gid, "iid" => iid}) do
    case Groups.get_group(gid) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{message: :group_not_found})

      group ->
        case Groups.remove_instance(group, iid) do
          {1, nil} ->
            send_resp(conn, :no_content, "")

          {:error, _reason} ->
            conn
            |> put_status(404)
            |> json(%{message: :instance_not_found})
        end
    end
  end
end
