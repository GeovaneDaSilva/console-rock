module Devices
  # An device's agent log
  class AgentLog < ApplicationRecord
    belongs_to :device
    belongs_to :upload
  end
end
