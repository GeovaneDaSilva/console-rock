class CreateDeletedCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :deleted_customers do |t|
      t.string :license_key
      t.jsonb :details, default: '{}'

      t.timestamps
    end

    add_index :deleted_customers, :license_key
  end
end
