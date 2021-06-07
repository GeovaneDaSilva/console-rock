class DropAuditTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :audit_users
    drop_table :audit_user_roles
    drop_table :audit_accounts
    drop_table :audit_incidents
    drop_table :audit_logic_rules
    drop_table :audit_credentials
    drop_table :audit_agent_releases
    drop_table :audit_app_configs
  end
end
