defmodule Portal.Plug.DevProxy do
  use HTTPoison.Base
  use Plug.Router

  @portal_host "http://localhost:8080"
  @game_host "http://localhost:8081"

  def process_url(url) do
    cond do
      String.starts_with?(url, "/portal") -> @portal_host <> url
      String.starts_with?(url, "/game") -> @game_host <> url
      true -> url
    end
  end

  plug(:match)
  plug(:dispatch)

  # catch all `get`s
  get _ do
    %{method: "GET", request_path: request_path, params: params, req_headers: req_headers} = conn

    if Application.get_env(:rc, :disallow_mp3) and String.ends_with?(request_path, ".mp3") do
      send_resp(conn, 404, "")
    else
      res = get!(request_path, req_headers, params: Map.to_list(params))
      send_response({:ok, conn, res})
    end
  end

  defp send_response({:ok, conn, %{headers: headers, status_code: status_code, body: body}}) do
    conn = %{conn | resp_headers: headers}
    send_resp(conn, status_code, body)
  end
end

defmodule EnvOnly do
  defmacro test(do: block) do
    if Mix.env() == :test do
      block
    end
  end

  defmacro dev(do: block) do
    if Mix.env() == :dev do
      block
    end
  end

  defmacro not_prod(do: block) do
    if Mix.env() != :prod do
      block
    end
  end

  defmacro prod(do: block) do
    if Mix.env() == :prod do
      block
    end
  end
end
