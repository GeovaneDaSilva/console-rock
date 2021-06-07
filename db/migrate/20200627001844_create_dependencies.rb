class CreateDependencies < ActiveRecord::Migration[5.2]
  def up
    add_column :logic_rules, :dependencies, :string, array: true
    change_column_default :logic_rules, :dependencies, []
  end
  def down
    remove_column :logic_rules, :dependencies
  end
end
