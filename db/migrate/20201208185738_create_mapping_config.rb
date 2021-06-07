class CreateMappingConfig < ActiveRecord::Migration[5.2]
  def change
    create_table :mapping_configs do |t|
      t.integer :account_id
      t.ltree   :account_path
      t.string  :map_type
      t.jsonb   :details
    end
  end
end
