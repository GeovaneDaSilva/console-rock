class RmOldThreatsIndicatorColumns < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      remove_column :threats_indicators, :device_id, :string, index: true, null: false
      remove_column :threats_indicators, :details, :string, null: false
    end
  end
end
