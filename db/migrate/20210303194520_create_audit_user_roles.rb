class CreateAuditUserRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :audit_user_roles do |t|
      t.integer   :user_role_id
      t.integer   :done_by_user_id
      t.column    :action, "char(2)"
      t.string    :data

      t.timestamps
    end
  end
end
