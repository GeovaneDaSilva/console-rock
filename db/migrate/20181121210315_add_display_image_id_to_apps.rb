class AddDisplayImageIdToApps < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_column :apps, :display_image_id, :string
    add_index :apps, :display_image_id, algorithm: :concurrently
  end
end
