module Devices
  # Denotes a hunt that is queued to run
  class QueuedHunt < ApplicationRecord
    belongs_to :device
    belongs_to :hunt

    validates :hunt_id, uniqueness: { scope: :device_id }
    validate :needs_queued

    private

    def needs_queued
      return if device.hunt_results.where(hunt_id: hunt.id, revision: hunt.revision).none?

      errors.add(:hunt_id, "hunt result already exists for hunt revision")
    end
  end
end
