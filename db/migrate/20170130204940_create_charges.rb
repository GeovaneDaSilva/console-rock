class CreateCharges < ActiveRecord::Migration[5.0]
  def change
    create_table :charges do |t|
      t.integer :status, null: false, default: 0
      t.monetize :amount, null: false, default: 0
      t.integer :provider_id, null: false
      t.integer :plan_id, null: false

      t.timestamps
    end

    add_index :charges, :provider_id
    add_index :charges, :plan_id
  end
end
