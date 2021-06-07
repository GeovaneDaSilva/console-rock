module Devices
  # Track device connects and disconnects
  class ConnectivityLog < ApplicationRecord
    belongs_to :device
    has_one :customer, through: :device

    validates :device_id, :connected_at, :disconnected_at, :duration, presence: true
    before_validation :update_duration

    after_commit do
      customer.with_lock { customer.touch } if customer
    end

    private

    def update_duration
      self.duration = disconnected_at - connected_at if disconnected_at.present?
    end
  end
end
