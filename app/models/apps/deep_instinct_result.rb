module Apps
  # :nodoc
  class DeepInstinctResult < Apps::CloudResult
    def closed?
      details&.status == "CLOSED" || details&.close_timestamp.present? || details&.close_trigger.present?
    end

    def recorded_device_hostname
      details&.recorded_device_info&.dig("hostname")
    end

    def details_type
      details.attributes&.dig("type")
    end
  end
end
