defmodule Portal.Plug.AuthErrorHandler do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  @behaviour Guardian.Plug.ErrorHandler

  @codes %{
    unauthenticated: 401,
    unauthorized: 401,
    forbidden: 403
  }

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    accept = extract_accept(conn)
    body = to_string(type)

    code = Map.get(@codes, type, 500)

    case String.contains?(accept, "text/html") do
      true ->
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(code, body)
        |> halt()

      false ->
        conn
        |> put_status(code)
        |> json(%{message: body})
        |> halt()
    end
  end

  defp extract_accept(conn) do
    get_req_header(conn, "accept")
    |> case do
      [] -> ""
      [accept] -> accept
    end
    |> case do
      "" -> "text/html"
      accept -> accept
    end
  end
end
