defmodule RC.Repo do
  use Ecto.Repo,
    otp_app: :rc,
    adapter: Ecto.Adapters.Postgres

  use Scrivener,
    page_size: 50

  def format_errors(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
