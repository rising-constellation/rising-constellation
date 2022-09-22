defmodule RC.Repo.Migrations.JsonbSpeedSizeIndexes do
  use Ecto.Migration

  def up do
    execute("CREATE INDEX scenarios_metadata_index_1 ON scenarios USING GIN (game_metadata);")
    execute("CREATE INDEX scenarios_metadata_index_2 ON scenarios USING GIN (game_metadata jsonb_path_ops);")
  end

  def down do
    execute("DROP INDEX scenarios_metadata_index_1;")
    execute("DROP INDEX scenarios_metadata_index_2;")
  end
end
