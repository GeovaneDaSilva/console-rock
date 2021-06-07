class CreateAuditAppConfigs < ActiveRecord::Migration[5.2]
  def change
    create_table :audit_app_configs do |t|
      t.integer   :app_config_id
      t.integer   :done_by_user_id
      t.column    :action, "char(2)"
      t.string    :data

      t.timestamps
    end
  end
end
