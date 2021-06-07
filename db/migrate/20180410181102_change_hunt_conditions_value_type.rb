class ChangeHuntConditionsValueType < ActiveRecord::Migration[5.1]
  def change
    safety_assured { change_column(:hunts_conditions, :value, :text) }
  end
end
