class AlterRemediations < ActiveRecord::Migration[5.2]
  def change
    add_column :remediations, :active, :boolean
    add_column :remediations, :status_detail, :string
  end
end
