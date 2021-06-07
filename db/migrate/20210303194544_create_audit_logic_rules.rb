class CreateAuditLogicRules < ActiveRecord::Migration[5.2]
  def change
    create_table :audit_logic_rules do |t|
      t.integer   :logic_rule_id
      t.integer   :done_by_user_id
      t.column    :action, "char(2)"
      t.string    :data

      t.timestamps
    end
  end
end
