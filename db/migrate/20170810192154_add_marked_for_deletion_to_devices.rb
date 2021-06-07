class AddMarkedForDeletionToDevices < ActiveRecord::Migration[5.0]
  def change
    add_column :devices, :marked_for_deletion, :boolean, default: false, null: false
  end
end
