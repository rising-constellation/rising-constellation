defmodule Asylamba.Repo.Migrations.Enums do
  use Ecto.Migration

  def change do
    AccountRole.create_type()
    AccountStatus.create_type()
    LogAction.create_type()
    RegistrationStatus.create_type()
    InstanceStatus.create_type()
    GameStatus.create_type()

    rename(table("accounts"), :role, to: :old_role)
    rename(table("accounts"), :status, to: :old_status)
    rename(table("logs"), :action, to: :old_action)
    rename(table("registrations"), :status, to: :old_status)
    rename(table("instances"), :status, to: :old_status)
    rename(table("instances"), :game_status, to: :old_game_status)

    alter table("accounts") do
      add(:role, AccountRole.type())
      add(:status, AccountStatus.type())
    end

    alter table("logs") do
      add(:action, LogAction.type())
    end

    alter table("registrations") do
      add(:status, RegistrationStatus.type())
    end

    alter table("instances") do
      add(:status, InstanceStatus.type())
      add(:game_status, GameStatus.type())
    end

    Ecto.Migration.execute("""
      UPDATE accounts
      SET role = (
        SELECT (ENUM_RANGE(NULL::account_role))[s]
        FROM   generate_series(1, 10) s where s = old_role
      );
    """)

    Ecto.Migration.execute("""
      UPDATE accounts
      SET status = (
        SELECT (ENUM_RANGE(NULL::account_status))[s]
        FROM   generate_series(1, 10) s where s = old_status
      );
    """)

    Ecto.Migration.execute("""
      UPDATE logs
      SET action = (
        SELECT (ENUM_RANGE(NULL::log_action))[s]
        FROM   generate_series(1, 10) s where s = old_action
      );
    """)

    Ecto.Migration.execute("""
      UPDATE registrations
      SET status = (
        SELECT (ENUM_RANGE(NULL::registration_status))[s]
        FROM   generate_series(1, 10) s where s = old_status
      );
    """)

    Ecto.Migration.execute("""
      UPDATE instances
      SET status = (
        SELECT (ENUM_RANGE(NULL::instance_status))[s]
        FROM   generate_series(1, 10) s where s = old_status
      );
    """)

    Ecto.Migration.execute("""
      UPDATE instances
      SET game_status = (
        SELECT (ENUM_RANGE(NULL::game_status))[s]
        FROM   generate_series(1, 10) s where s = old_game_status
      );
    """)

    alter table("accounts") do
      remove(:old_role, AccountRole.type())
      remove(:old_status, AccountStatus.type())
    end

    alter table("logs") do
      remove(:old_action, LogAction.type())
    end

    alter table("registrations") do
      remove(:old_status, RegistrationStatus.type())
    end

    alter table("instances") do
      remove(:old_status, InstanceStatus.type())
      remove(:old_game_status, GameStatus.type())
    end
  end
end
