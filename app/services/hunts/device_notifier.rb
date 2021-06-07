module Hunts
  # Send hunts ws message for devices which are online but not running hunts
  # This is mostly to work around an agent bug
  class DeviceNotifier
    def call
      return
      device_ids.each do |device_id|
        Devices::QueuedHunt.where(device_id: device_id).includes(:hunt).find_each do |queued_hunt|
          queued_hunt.destroy && next if queued_hunt.hunt.nil?

          msg = {
            type: "hunts", payload: {
              hunt_id: queued_hunt.hunt.id, hunt_revision: queued_hunt.hunt.revision
            }
          }

          ServiceRunnerJob.set(wait: rand_wait, queue: :utility).perform_later(
            "DeviceBroadcasts::Device", device_id, msg.to_json, true
          )
        end
      end
    end

    private

    def rand_wait
      SecureRandom.rand(0.0..600.0).seconds
    end

    def device_ids
      Devices::QueuedHunt.joins(:device)
                         .where(devices: { connectivity: Device.connectivities[:online] })
                         .select(:device_id)
                         .distinct
                         .pluck(:device_id)
    end
  end
end
