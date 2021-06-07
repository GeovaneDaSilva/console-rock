module Hunts
  # Creates Devices::QueuedHunt records for a given context
  class DeviceQueuer
    def initialize(record, notify_devices = true)
      @record = record
      @notify_devices = notify_devices
    end

    def call
      return
      if @record.is_a?(Hunt)
        queue_all_devices_for_hunt
      elsif @record.is_a?(Device)
        queue_all_hunts_for_device
      elsif @record.is_a?(Group)
        queue_all_hunts_for_all_devices_for_group
      end
    end

    private

    def queue_all_devices_for_hunt
      return unless @record.group

      i = 0.0
      @record.group.device_query.find_each do |device|
        ServiceRunnerJob.set(queue: :utility, wait: i.seconds)
                        .perform_later(self.class.name, device, @notify_devices)
        i += 0.5
      end
    end

    def queue_all_hunts_for_device
      Group.where(id: @record.group_ids).find_each do |group|
        group.hunts.where(updated_at: 1.day.ago..DateTime.current).find_each do |hunt|
          queue_hunt(@record, hunt)
        end
      end
    end

    def queue_all_hunts_for_all_devices_for_group
      i = 0.0
      @record.device_query.find_each do |device|
        ServiceRunnerJob.set(queue: :utility, wait: i.seconds)
                        .perform_later(self.class.name, device, @notify_devices)
        i += 0.5
      end
    end

    def queue_hunt(device, hunt)
      qh = Devices::QueuedHunt.create(hunt: hunt, device: device)
      device_broadcast(device, hunt) if qh.persisted? # maybe not valid
    rescue ActiveRecord::RecordNotUnique
      # Do nothing, already queued
    end

    def device_broadcast(device, hunt)
      return unless @notify_devices

      ServiceRunnerJob.perform_later(
        "DeviceBroadcasts::Device", device.id, broadcast_message_for_hunt(hunt).to_json,
        true
      )
    end

    def broadcast_message_for_hunt(hunt)
      { type: "hunts", payload: { hunt_id: hunt.id, hunt_revision: hunt.revision } }
    end
  end
end
