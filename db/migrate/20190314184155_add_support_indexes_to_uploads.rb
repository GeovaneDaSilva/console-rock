class AddSupportIndexesToUploads < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :uploads, [:support_file, :protected], algorithm: :concurrently
    add_index :uploads, :status, algorithm: :concurrently
  end
end
