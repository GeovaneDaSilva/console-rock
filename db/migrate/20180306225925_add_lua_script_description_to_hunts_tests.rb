class AddLuaScriptDescriptionToHuntsTests < ActiveRecord::Migration[5.1]
  def change
    add_column :hunts_tests, :lua_script_description, :string
  end
end
