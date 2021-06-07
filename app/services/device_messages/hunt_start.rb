module DeviceMessages
  # Processes hunt_start messages sent by a device
  class HuntStart < Base
    def call
      return if hunt.continuous

      if latest?
        Rails.cache.write("device_#{device.id}:hunt_#{hunt.id}", DateTime.current)
        ActionCable.server.broadcast(
          "device_#{device.id}:hunt_#{hunt.id}", hunt_entry
        )
      end

      Rails.cache.write("device_#{device.id}:hunt_#{hunt.id}_#{revision}", DateTime.current)
      ActionCable.server.broadcast(
        "device_#{device.id}:hunt_#{hunt.id}_#{revision}", hunt_entry
      )

      true
    end

    private

    def hunt
      @hunt ||= Hunt.find(payload.dig("id"))
    end

    def revision
      @revision ||= payload.dig("revision")
    end

    def latest?
      revision == hunt.revision
    end

    def timestamp
      hunt.hunt_results.where(device: device).last&.created_at || hunt.updated_at
    end

    def hunt_entry
      AuthenticatedController.renderer.render(
        partial: "hunts/device_hunt_results",
        locals:  {
          status: "running", name: hunt.name,
          hostname: device.hostname, timestamp: timestamp,
          result_path: nil, device: device, hunt: hunt
        }
      ).squish
    end
  end
end
