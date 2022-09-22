defmodule Portal.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use Portal, :controller

  require Logger

  def call(conn, {:error, %Ecto.Changeset{errors: [_ | _], valid?: false} = changeset}) do
    conn
    |> put_status(400)
    |> json(%{message: RC.Repo.format_errors(changeset)})
  end

  # Repo.transaction error
  def call(
        conn,
        {:error, _failed_operation, %Ecto.Changeset{valid?: false} = changeset, _changes_so_far}
      ) do
    conn
    |> put_status(400)
    |> json(%{message: RC.Repo.format_errors(changeset)})
  end

  def call(conn, {:error, failed_operation, failed_value, _changes_so_far}) do
    Logger.info("#{inspect(failed_operation)}, failed value: #{inspect(failed_value)}")

    conn
    |> put_status(400)
    |> json(%{message: RC.Repo.format_errors(failed_value)})
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(404)
    |> json(%{message: :not_found})
  end

  def call(conn, {:error, %ArgumentError{}}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(Portal.ErrorView)
    |> render(:"422")
  end

  def call(conn, {:error, reason}) do
    Logger.info("#{inspect(reason)}")

    conn
    |> put_status(500)
    |> json(%{message: :general_error})
  end

  def call(conn, :error) do
    conn
    |> put_status(500)
    |> json(%{message: :general_error})
  end
end
