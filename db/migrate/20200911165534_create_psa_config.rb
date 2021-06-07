class CreatePsaConfig < ActiveRecord::Migration[5.2]
  def change
    create_table :psa_configs do |t|
      t.integer :account_id, null: false
      t.integer :credential_id, null: false
      t.jsonb :configs

      t.timestamps
    end

    add_index :psa_configs, :account_id
  end
end
