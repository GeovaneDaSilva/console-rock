class AddLuaScriptUploadIdToHuntsTests < ActiveRecord::Migration[5.1]
  def change
    add_column :hunts_tests, :lua_script_upload_id, :string
    add_index :hunts_tests, :lua_script_upload_id
  end
end
