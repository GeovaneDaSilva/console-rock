class AddThreatIndicatorValueTypeIndex < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :threats_indicators, [:indicator_type, :value], algorithm: :concurrently
    add_column :threats_indicators, :indicator_devices_count, :integer
    change_column_default :threats_indicators, :indicator_devices_count, from: nil, to: 0
  end
end
