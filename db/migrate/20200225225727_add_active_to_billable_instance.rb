class AddActiveToBillableInstance < ActiveRecord::Migration[5.2]
  def change
    add_column :billable_instances, :active, :boolean

    reversible do |dir|
      dir.up do
        BillableInstance.update_all(active: true)
      end
    end
  end
end
