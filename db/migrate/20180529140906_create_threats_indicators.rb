class CreateThreatsIndicators < ActiveRecord::Migration[5.2]
  def change
    create_table :threats_indicators do |t|
      t.string :device_id, index: true, null: false
      t.integer :indicator_type, null: false, default: 0
      t.text :value, null: false
      t.jsonb :details, null: false

      t.timestamps
    end
  end
end
