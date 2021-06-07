class AddSupportFileFlagToUploads < ActiveRecord::Migration[5.0]
  def change
    add_column :uploads, :support_file, :boolean, default: false, null: false
  end
end
