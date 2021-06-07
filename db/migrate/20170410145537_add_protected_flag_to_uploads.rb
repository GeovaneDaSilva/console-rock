class AddProtectedFlagToUploads < ActiveRecord::Migration[5.0]
  def change
    add_column :uploads, :protected, :boolean, default: false, null: false
  end
end
