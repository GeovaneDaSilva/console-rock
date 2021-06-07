class AddAdditionalTypesToApps < ActiveRecord::Migration[5.2]
  def change
    add_column :apps, :additional_types, :text, array: true

    change_column_default :apps, :additional_types, from: nil, to: []
  end
end
