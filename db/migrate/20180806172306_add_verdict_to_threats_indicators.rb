class AddVerdictToThreatsIndicators < ActiveRecord::Migration[5.2]
  def change
    add_column :threats_indicators, :verdict, :integer
    change_column_default :threats_indicators, :verdict, from: nil, to: 0
  end
end
