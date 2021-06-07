class AddOnByDefaultToApps < ActiveRecord::Migration[5.2]
  def change
    add_column :apps, :on_by_default, :boolean
  end
end
