class AddLookupSkus < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    create_table :lookup_skus, id: :string do |t|
      t.string :name

      t.timestamps
    end

    add_index :lookup_skus, :name, algorithm: :concurrently
  end
end
