class UpdateGroupsToUseExplicitOsInformation < ActiveRecord::Migration[5.0]
  def change
    remove_column :groups, :os

    add_column :groups, :family_version_and_edition, :string
    add_column :groups, :architecture, :string
  end
end
