class AddDescriptionToLogicRules < ActiveRecord::Migration[5.2]
  def change
    add_column :logic_rules, :description, :text
  end
end
