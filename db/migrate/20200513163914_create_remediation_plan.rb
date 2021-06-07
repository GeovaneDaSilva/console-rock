class CreateRemediationPlan < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    create_table :remediation_plans do |t|
      t.string    :account_path
      t.integer   :incident_id
      t.text      :isolation_list, array: true, default: []

      t.timestamps
    end

    add_index :remediation_plans, :incident_id, algorithm: :concurrently
    add_index :remediation_plans, :account_path, algorithm: :concurrently
  end
end
