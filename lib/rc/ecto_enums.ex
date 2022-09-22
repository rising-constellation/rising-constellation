import EctoEnum

# rc/accounts
defenum(AccountRole, :account_role, [:user, :admin])
defenum(AccountStatus, :account_status, [:registered, :active, :inactive, :deleted, :banned])
defenum(TokenType, :token_type, [:email_verification, :password_reset, :email_update])

# rc/logs
defenum(LogAction, :log_action, [
  :create_account,
  :login,
  :update_restricted,
  :update,
  :update_with_email,
  :account_validation,
  :reset_password
])

# rc/instances/registration
defenum(RegistrationStatus, :registration_status, [:active, :inactive])

# rc/instances/instance
defenum(InstanceRegistrationStatus, :instance_registration_status, [:preregistration, :open, :closed])
defenum(InstanceMaintenanceStatus, :instance_maintenance_status, [:none, :automatic, :short, :long])
defenum(InstanceGameStatus, :instance_game_status, [:closed, :open])
defenum(InstanceDisplayStatus, :instance_display_status, [:hidden, :overview, :detail])
defenum(InstanceSupervisorStatus, :instance_supervisor_status, [:not_instantiated, :instantiated, :running])
# old one used in migrations
defenum(GameStatus, :game_status, [:not_instantiated, :not_running, :running])
defenum(InstanceStatus, :instance_status, [:hidden, :visible, :open])

defenum(ScenarioStartSettings, :instance_start_settings, [:auto, :when_full, :manual])

defenum(InstanceRegistrationType, :registration_type, [:pre_registration, :late_registration])
defenum(InstanceGameType, :instance_game_type, [:historical, :official, :public, :private])
