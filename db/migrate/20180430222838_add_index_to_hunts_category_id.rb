class AddIndexToHuntsCategoryId < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index :hunts, :category_id, algorithm: :concurrently
  end
end
