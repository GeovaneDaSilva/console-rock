class CreateFirewallCounters < ActiveRecord::Migration[5.2]
  def change
    create_table :firewall_counters do |t|
      t.ltree :account_path, null: false
      t.integer :count, null: false, default: 0
      t.integer :firewall_type, null: false
      t.integer :count_type, null: false
      t.integer :billable_instance_id

      t.timestamps
    end

    add_index :firewall_counters, :account_path, using: :gist
  end
end
