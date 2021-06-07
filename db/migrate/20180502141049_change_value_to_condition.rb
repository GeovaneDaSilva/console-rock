class ChangeValueToCondition < ActiveRecord::Migration[5.2]
  def change
    safety_assured { rename_column :hunts_conditions, :value, :condition }
  end
end
