class AddRequiredToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :required, :boolean
  end
end
