defmodule RC.Repo.Migrations.CreateMessenger do
  use Ecto.Migration

  def change do
    create table(:conversations) do
      add(:name, :string)
      add(:is_group, :boolean)
      add(:is_between_profiles, :boolean)

      timestamps()
    end

    create table(:conversation_members) do
      add(:is_admin, :boolean)
      add(:last_seen, :utc_datetime_usec)

      add(:conversation_id, references(:conversations, on_delete: :delete_all), null: false)
      add(:account_id, references(:accounts, on_delete: :nothing), null: false)
      add(:profil_id, references(:profils, on_delete: :nothing))

      timestamps()
    end

    create(index(:conversation_members, [:conversation_id]))
    create(index(:conversation_members, [:account_id]))
    create(index(:conversation_members, [:profil_id]))

    create(unique_index("conversation_members", [:conversation_id, :account_id, :profil_id], name: :conv_member_unique))

    # create 'empty' constraint, it will be raised by `check_profiles_on_conversations()`
    create(constraint("conversation_members", :conversation_requires_profiles, check: "true"))

    create table(:messages) do
      add(:content_raw, :string)
      add(:content_html, :string)

      add(:conversation_member_id, references(:conversation_members, on_delete: :delete_all), null: false)

      add(:conversation_id, references(:conversations, on_delete: :nothing), null: false)

      timestamps(type: :utc_datetime_usec)
    end

    create(index(:messages, [:conversation_member_id]))
    create(index(:messages, [:conversation_id]))

    execute(
      # up
      ~S"""
      CREATE FUNCTION check_profiles_on_conversations() RETURNS TRIGGER AS $$
      BEGIN
        IF EXISTS(
            SELECT 1
            FROM conversations as c
            WHERE c.id = NEW.conversation_id
            AND c.is_between_profiles = TRUE
            AND NEW.profil_id IS NULL
          )
        THEN
          RAISE CHECK_VIOLATION
          USING CONSTRAINT = 'conversation_requires_profiles';
        END IF;
        RETURN NEW;
      END;
      $$ language plpgsql;
      """,

      # down
      "DROP FUNCTION check_profiles_on_conversations;"
    )

    execute(
      # up
      ~S"""
      CREATE TRIGGER _check_profiles_on_conversations
      BEFORE INSERT ON conversation_members
      FOR EACH ROW
      EXECUTE PROCEDURE check_profiles_on_conversations();
      """,

      # down
      "DROP TRIGGER _check_profiles_on_conversations ON conversation_members;"
    )
  end
end
