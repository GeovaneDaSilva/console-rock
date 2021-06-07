class AddTagsToUploads < ActiveRecord::Migration[5.2]
  def change
    add_column :uploads, :tags, :text, array: true

    change_column_default :uploads, :tags, from: nil, to: []

    Upload.update_all(tags: [])
  end
end
