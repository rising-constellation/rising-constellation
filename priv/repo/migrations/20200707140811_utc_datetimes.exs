defmodule RC.Repo.Migrations.UtcDatetimesMicrosec do
  use Ecto.Migration

  def change do
    # For each of the listed tables, change the type of :inserted_at and :updated_at to microsecond precision
    ~w/account_tokens accounts blog_categories blog_comments blog_posts conversation_members conversations factions groups instance_snapshots instances logs models player_stats profiles registrations/
    |> Enum.map(&String.to_atom/1)
    |> Enum.each(fn table_name ->
      alter table(table_name) do
        modify(:inserted_at, :utc_datetime_usec)
        modify(:updated_at, :utc_datetime_usec)
      end
    end)

    alter table("player_report") do
      modify(:inserted_at, :utc_datetime_usec)
    end

    alter table("instances") do
      modify(:opening_date, :utc_datetime_usec)
    end
  end
end
