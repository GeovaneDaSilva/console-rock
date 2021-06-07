class RemoveDependencies < ActiveRecord::Migration[5.2]
  def up
     safety_assured { remove_column :logic_rules, :dependencies }
   end
   def down
     add_column :logic_rules, :dependencies, :integer, array: true
   end
end
