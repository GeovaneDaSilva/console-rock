class ChangeUploadSourceableIdToString < ActiveRecord::Migration[5.0]
  def change
    change_column :uploads, :sourceable_id, :string
  end
end
