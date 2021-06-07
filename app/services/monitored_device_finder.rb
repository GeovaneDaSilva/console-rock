# Finds the monitored devices for a given Account
class MonitoredDeviceFinder
  def initialize(account, start_date, end_date = nil)
    @account = account
    @start_date = start_date.to_datetime
    @end_date = (end_date || DateTime.current.beginning_of_day).to_datetime
  end

  def call
    @account
      .all_descendant_devices
      .joins(:connectivity_logs)
      .where(devices_connectivity_logs: { connected_at: @start_date..@end_date })
      .distinct
  end
end
