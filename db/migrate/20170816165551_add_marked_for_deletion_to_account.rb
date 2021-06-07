class AddMarkedForDeletionToAccount < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :marked_for_deletion, :boolean, default: false, null: false
  end
end
