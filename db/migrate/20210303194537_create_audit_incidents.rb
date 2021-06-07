class CreateAuditIncidents < ActiveRecord::Migration[5.2]
  def change
    create_table :audit_incidents do |t|
      t.integer   :incident_id
      t.integer   :done_by_user_id
      t.column    :action, "char(2)"
      t.string    :data

      t.timestamps
    end
  end
end
