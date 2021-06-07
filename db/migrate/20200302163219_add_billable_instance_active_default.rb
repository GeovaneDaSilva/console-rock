class AddBillableInstanceActiveDefault < ActiveRecord::Migration[5.2]
  def change
    change_column_default :billable_instances, :active, from: nil, to: true

    reversible do |dir|
      dir.up { BillableInstance.where(active: nil).update_all(active: true) }
    end
  end
end
