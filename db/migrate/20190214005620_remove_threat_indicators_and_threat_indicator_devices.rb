class RemoveThreatIndicatorsAndThreatIndicatorDevices < ActiveRecord::Migration[5.2]
  def change
    drop_table :threats_indicator_devices
    drop_table :threats_indicators
  end
end
