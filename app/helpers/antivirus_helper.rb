# :nodoc
module AntivirusHelper
  def matching_hostname?(hostname)
    active_device = existing_devices.where(hostname: hostname)
    return false if active_device.blank?

    true
  end

  def existing_devices
    # rubocop: disable Rails/HelperInstanceVariable
    @account.all_descendant_devices
    # rubocop: enable Rails/HelperInstanceVariable
  end
end
