class ChangeUploadStatusDefault < ActiveRecord::Migration[5.2]
  def change
    change_column_default :uploads, :status, from: nil, to: 0
  end
end
