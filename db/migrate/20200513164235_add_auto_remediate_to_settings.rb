class AddAutoRemediateToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :auto_remediate, :boolean
  end
end
