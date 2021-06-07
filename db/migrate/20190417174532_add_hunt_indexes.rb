class AddHuntIndexes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :hunts, :indicator, algorithm: :concurrently
    add_index :hunts, :continuous, algorithm: :concurrently
    add_index :hunts, :disabled, algorithm: :concurrently
  end
end
