module DeviceMessages
  # Lookup cached IP info
  class IpInfo < Base
    include ::ApiClients::ApiLimits::IpInfo

    def call
      # Devices don't care when ip info is returned
      # Wait for the API limit to subside before trying again
      if ip_record.nil? && api_limit.exceeded?
        ServiceRunnerJob.set(wait: rand(60..90).minutes, queue: "ip_info")
                        .perform_later(self.class.name, @message)
      elsif response_record
        respond_to_device
      end
    end

    private

    def respond_to_device
      ServiceRunnerJob.set(queue: "pushed-tasks").perform_later(
        "DeviceBroadcasts::Device", device.id, response.to_json, true
      )
    end

    def response
      {
        type: "ip_info", payload: {
          ip:      response_record.id,
          details: response_record.as_json.except(:id, :created_at),
          meta:    payload["meta"]
        }
      }
    end

    def ip
      payload.fetch("ip")
    end

    def response_record
      # can return nil, so ||= doesn't work well here
      @response_record = find_or_create_ip_record unless defined?(@response_record)

      @response_record
    end

    def ip_record
      @ip_record ||= CachedIp.find(ip)
    end

    def find_or_create_ip_record
      return ip_record unless ip_record.nil?

      data = Geocoder.search(ip)&.first&.data&.with_indifferent_access

      return unless data

      @ip_record = CachedIp.create(
        data.extract!(:city, :region, :country, :loc).merge(id: ip),
        expires_in: 2.months
      )
    end

    def api_key
      ENV["IPINFO_API_KEY"]
    end
  end
end
