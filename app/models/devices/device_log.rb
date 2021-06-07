module Devices
  # Logs uploaded from a device
  class DeviceLog < ApplicationRecord
    belongs_to :device
    belongs_to :upload
    belongs_to :customer
  end
end
