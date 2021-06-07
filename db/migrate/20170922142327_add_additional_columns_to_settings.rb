class AddAdditionalColumnsToSettings < ActiveRecord::Migration[5.1]
  def change
    add_column :settings, :uninstall, :boolean, default: false, null: false
    add_column :settings, :url, :string
    add_column :settings, :license_key, :string
    add_column :settings, :verbosity, :integer, default: 2, null: false
    add_column :settings, :offline, :boolean, default: false, null: false
    add_column :settings, :super, :boolean, default: false, null: false
    add_column :settings, :polling, :integer, default: 60, null: false
  end
end
