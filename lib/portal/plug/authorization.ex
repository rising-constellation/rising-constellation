defmodule Portal.Plug.Authorization do
  require Logger

  alias RC.Groups
  alias RC.Messenger
  alias RC.Blog
  alias RC.Accounts
  alias RC.Instances
  alias Portal.Plug.AuthErrorHandler

  def init(options), do: options

  def call(%{private: private} = conn, atom) do
    if Map.has_key?(private, :guardian_default_resource) do
      validate(conn, atom)
    else
      http_error(conn, 401)
    end
  end

  def validate(conn, :admin) do
    case admin?(conn) do
      true -> conn
      _ -> http_error(conn, 403)
    end
  end

  def validate(conn, :own_resource) do
    case admin?(conn) or own_resource?(conn) do
      true -> conn
      _ -> http_error(conn, 403)
    end
  end

  def validate(conn, :group_resource) do
    case admin?(conn) or group_resource?(conn) do
      true -> conn
      _ -> http_error(conn, 403)
    end
  end

  def validate(conn, :conversation_admin) do
    case admin?(conn) or conversation_admin?(conn) do
      true -> conn
      _ -> http_error(conn, 403)
    end
  end

  def validate(conn, :conversation_member) do
    case admin?(conn) or conversation_member?(conn) do
      true -> conn
      _ -> http_error(conn, 403)
    end
  end

  def validate(conn, _atom) do
    http_error(conn, 403)
  end

  defp admin?(conn) do
    conn.private.guardian_default_resource.role == :admin
  end

  defp own_resource?(%{params: %{"aid" => id}} = conn) do
    with true <- is_binary(id),
         {id, _} <- Integer.parse(id) do
      conn.private.guardian_default_resource.id == id
    else
      _ -> false
    end
  end

  # for blog comments
  defp own_resource?(%{params: %{"bcid" => blog_comment_id}} = conn) do
    account_id = conn.private.guardian_default_resource.id

    Blog.own_comment?(account_id, blog_comment_id)
  end

  # for profiles
  defp own_resource?(%{params: %{"pid" => profile_id}} = conn) do
    account_id = conn.private.guardian_default_resource.id

    Accounts.own_profile?(account_id, profile_id)
  end

  # for instances actions
  defp own_resource?(%{params: %{"iid" => instance_id}} = conn) do
    account_id = conn.private.guardian_default_resource.id

    Instances.own_instance?(account_id, instance_id)
  end

  defp group_resource?(%{params: %{"iid" => instance_id}} = conn) do
    account_id = conn.private.guardian_default_resource.id

    if Groups.instance_in_group?(instance_id) do
      Groups.instance_access?(account_id, instance_id)
    else
      true
    end
  end

  defp group_resource?(conn) do
    account_id = conn.private.guardian_default_resource.id

    Groups.blog_author?(account_id)
  end

  defp conversation_member?(%{params: %{"pid" => profile_id, "cid" => conversation_id}} = conn) do
    account_id = conn.private.guardian_default_resource.id

    Messenger.conversation_member?(conversation_id, account_id, profile_id)
  end

  defp conversation_admin?(%{params: %{"cid" => conversation_id, "pid" => profile_id}} = conn) do
    account_id = conn.private.guardian_default_resource.id

    Messenger.conversation_admin?(conversation_id, account_id, profile_id)
  end

  defp http_error(conn, code) do
    case code do
      403 -> AuthErrorHandler.auth_error(conn, {:forbidden, ""}, %{})
      401 -> AuthErrorHandler.auth_error(conn, {:unauthorized, ""}, %{})
    end
  end
end
