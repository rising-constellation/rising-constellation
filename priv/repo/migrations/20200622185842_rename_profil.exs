defmodule RC.Repo.Migrations.RenameProfil do
  use Ecto.Migration

  def up do
    # d 1
    drop(constraint(:registrations, "registrations_profil_id_fkey"))
    # d 2
    drop(index(:registrations, [:profil_id]))

    # d 3
    drop(constraint(:conversation_members, "conversation_members_profil_id_fkey"))
    # d 4
    drop(unique_index("conversation_members", [:conversation_id, :account_id, :profil_id], name: :conv_member_unique))

    # d 5
    execute("DROP TRIGGER _check_profiles_on_conversations ON conversation_members;")
    # d 6
    execute("DROP FUNCTION check_profiles_on_conversations;")

    # u 6
    execute(~S"""
    CREATE FUNCTION check_profiles_on_conversations() RETURNS TRIGGER AS $$
    BEGIN
      IF EXISTS(
          SELECT 1
          FROM conversations as c
          WHERE c.id = NEW.conversation_id
          AND c.is_between_profiles = TRUE
          AND NEW.profile_id IS NULL
        )
      THEN
        RAISE CHECK_VIOLATION
        USING CONSTRAINT = 'conversation_requires_profiles';
      END IF;
      RETURN NEW;
    END;
    $$ language plpgsql;
    """)

    # u 5
    execute(~S"""
    CREATE TRIGGER _check_profiles_on_conversations
    BEFORE INSERT ON conversation_members
    FOR EACH ROW
    EXECUTE PROCEDURE check_profiles_on_conversations();
    """)

    # d 7
    drop(constraint(:profils, "profils_pkey"))
    # d 8
    drop(unique_index(:profils, [:name]))
    # d 9
    drop(index(:profils, [:account_id]))

    # Rename the table
    rename(table(:profils), to: table(:profiles))

    alter table(:profiles) do
      # u 7
      modify(:id, :bigint, primary_key: true)
    end

    # u 8
    create(unique_index(:profiles, [:name]))
    # u 9
    create(index(:profiles, [:account_id]))

    rename(table(:conversation_members), :profil_id, to: :profile_id)

    alter table(:conversation_members) do
      # u 3
      modify(:profile_id, references(:profiles, on_delete: :nothing))
    end

    # u 4
    create(
      unique_index("conversation_members", [:conversation_id, :account_id, :profile_id], name: :conv_member_unique)
    )

    rename(table(:registrations), :profil_id, to: :profile_id)

    alter table(:registrations) do
      # u 1
      modify(:profile_id, references(:profiles, on_delete: :delete_all), null: false)
    end

    # u 2
    create(index(:registrations, [:profile_id]))

    # Rename the ID sequence to keep the naming consistent.
    execute("ALTER SEQUENCE profils_id_seq RENAME TO profiles_id_seq;")
  end

  def down do
    drop(constraint(:registrations, "registrations_profile_id_fkey"))
    drop(index(:registrations, [:profile_id]))

    drop(constraint(:conversation_members, "conversation_members_profile_id_fkey"))
    drop(unique_index("conversation_members", [:conversation_id, :account_id, :profile_id], name: :conv_member_unique))

    execute("DROP TRIGGER _check_profiles_on_conversations ON conversation_members;")
    execute("DROP FUNCTION check_profiles_on_conversations;")

    execute(~S"""
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
    """)

    execute(~S"""
    CREATE TRIGGER _check_profiles_on_conversations
    BEFORE INSERT ON conversation_members
    FOR EACH ROW
    EXECUTE PROCEDURE check_profiles_on_conversations();
    """)

    drop(constraint(:profiles, "profiles_pkey"))
    drop(unique_index(:profiles, [:name]))
    drop(index(:profiles, [:account_id]))
    # Rename the table
    rename(table(:profiles), to: table(:profils))

    alter table(:profils) do
      modify(:id, :bigint, primary_key: true)
    end

    create(unique_index(:profils, [:name]))
    create(index(:profils, [:account_id]))

    rename(table(:conversation_members), :profile_id, to: :profil_id)

    alter table(:conversation_members) do
      modify(:profil_id, references(:profils, on_delete: :nothing))
    end

    create(unique_index("conversation_members", [:conversation_id, :account_id, :profil_id], name: :conv_member_unique))

    rename(table(:registrations), :profile_id, to: :profil_id)

    alter table(:registrations) do
      modify(:profil_id, references(:profils, on_delete: :delete_all), null: false)
    end

    create(index(:registrations, [:profil_id]))

    # Rename the ID sequence to keep the naming consistent.
    execute("ALTER SEQUENCE profiles_id_seq RENAME TO profils_id_seq;")
  end
end
