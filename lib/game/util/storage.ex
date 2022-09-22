defmodule Util.Storage do
  require Logger

  alias ExAws.S3

  @directory "./priv/_storage/"
  @bucket "instance-snapshots"

  def store(data, filename) do
    case Application.get_env(:rc, :environment) do
      :prod -> store_s3(data, filename)
      _ -> store_local(data, filename)
    end
  end

  def load(filename) do
    case Application.get_env(:rc, :environment) do
      :prod -> load_s3(filename)
      _ -> load_local(filename)
    end
  end

  def delete(filename) do
    case Application.get_env(:rc, :environment) do
      :prod -> delete_s3(filename)
      _ -> delete_local(filename)
    end
  end

  defp store_local(data, filename) do
    path = Path.join([@directory, filename])
    binary = :erlang.term_to_binary(data)

    case File.write(path, binary) do
      :ok ->
        stat = File.stat!(path)
        {:ok, stat.size}

      error ->
        error
    end
  end

  defp store_s3(data, filename) do
    path = Path.join(["snapshots", filename])
    binary = :erlang.term_to_binary(data)

    case S3.put_object(@bucket, path, binary) |> ExAws.request() do
      {:ok, _} ->
        {:ok, :erlang.byte_size(binary)}

      error ->
        Logger.error(inspect(error))
        error
    end
  end

  defp load_local(filename) do
    path = Path.join([@directory, filename])

    case File.read(path) do
      {:ok, binary} -> {:ok, :erlang.binary_to_term(binary)}
      error -> error
    end
  end

  defp load_s3(filename) do
    path = Path.join(["snapshots", filename])

    case S3.get_object(@bucket, path) |> ExAws.request() do
      {:ok, %{body: binary}} ->
        {:ok, :erlang.binary_to_term(binary)}

      error ->
        Logger.error(inspect(error))
        error
    end
  end

  defp delete_local(filename) do
    path = Path.join([@directory, filename])

    case File.rm(path) do
      :ok ->
        :ok

      error ->
        error
    end
  end

  defp delete_s3(filename) do
    path = Path.join(["snapshots", filename])

    case S3.delete_object(@bucket, path) |> ExAws.request() do
      {:ok, _} ->
        :ok

      error ->
        Logger.error(inspect(error))
        error
    end
  end
end
