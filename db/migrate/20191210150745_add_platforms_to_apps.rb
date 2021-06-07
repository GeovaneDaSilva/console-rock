class AddPlatformsToApps < ActiveRecord::Migration[5.2]
  def change
    add_column :apps, :platforms, :text, array: true
    change_column_default :apps, :platforms, from: nil, to: []
  end
end
