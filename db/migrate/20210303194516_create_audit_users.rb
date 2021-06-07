class CreateAuditUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :audit_users do |t|
      # t.integer   :target_user_id
      t.integer   :done_by_user_id
      t.column    :action, "char(2)"
      t.string    :data

      t.timestamps
    end
  end
end
