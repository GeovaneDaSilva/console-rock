class CreateGeocodedThreats < ActiveRecord::Migration[5.1]
  def change
    create_table :geocoded_threats do |t|
      t.string :value, null: false
      t.string :threatable_type, null: false
      t.string :threatable_id, null: false
      t.string :city
      t.string :country
      t.float :latitude, null: false
      t.float :longitude, null: false
      t.integer :account_id, null: false, index: true

      t.timestamps
    end

    add_index :geocoded_threats, [:threatable_type, :threatable_id]
  end
end
