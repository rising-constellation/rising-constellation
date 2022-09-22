defmodule Asylamba.Repo.Migrations.RenameBodys do
  use Ecto.Migration

  def change do
    Ecto.Migration.execute("""
      UPDATE instances
      SET game_data = replace(replace(game_data, '"bodys"', '"bodies"'), '"subbodys"', '"subbodies"');
    """)
  end
end
