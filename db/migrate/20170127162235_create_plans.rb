class CreatePlans < ActiveRecord::Migration[5.0]
  def change
    create_table :plans do |t|
      t.string :name, null: false
      t.text :description
      t.integer :frequency, null: false
      t.monetize :price_per_frequency, default: 0, null: false

      t.timestamps
    end
  end
end
