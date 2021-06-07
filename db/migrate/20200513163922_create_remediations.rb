class CreateRemediations < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    create_table :remediations, id: :uuid do |t|
      t.integer     :result_id
      t.integer     :status
      t.integer     :remediation_plan_id
      t.string      :type
      t.string      :target_id
      t.jsonb       :actions
      t.string      :duplicate_check

      t.timestamps
    end

    add_index :remediations, :result_id, algorithm: :concurrently
    add_index :remediations, :duplicate_check, algorithm: :concurrently
    add_index :remediations, :remediation_plan_id, algorithm: :concurrently
  end
end
