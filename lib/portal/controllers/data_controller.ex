defmodule Portal.DataController do
  use Portal, :controller

  action_fallback(Portal.FallbackController)

  def all_in_module(conn, %{"module" => module}) do
    metadata = [
      speed: :fast,
      mode: :prod
    ]

    case Data.Querier.string_to_module(module) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{message: :data_not_found})

      module ->
        values = Data.Querier.fetch_all(module, metadata)
        json(conn, values)
    end
  end

  def all(conn, _params) do
    metadata = [
      speed: :fast,
      mode: :prod
    ]

    values =
      Data.Querier.modules()
      |> Enum.filter(fn m -> m.export end)
      |> Enum.reduce(%{}, fn m, acc ->
        Map.put(acc, m.string, Data.Querier.fetch_all(m.module, metadata))
      end)

    json(conn, values)
  end

  # def one(conn, %{"module" => module, "key" => key}) do
  #   case Data.Querier.string_to_module(module) do
  #     nil ->
  #       conn
  #       |> put_status(404)
  #       |> json(%{message: :data_not_found})

  #     module ->
  #       value = Data.Querier.fetch_one(module, [], key)
  #       json(conn, value)
  #   end
  # end

  def random_name(conn, %{"module" => module, "size" => size}) do
    {size, _} = Integer.parse(size)

    case Data.Picker.name_to_file(module) do
      :file_not_found ->
        conn
        |> put_status(404)
        |> json(%{message: :data_not_found})

      _ ->
        values = Data.Picker.random_unsafe(module, size)
        json(conn, values)
    end
  end
end
