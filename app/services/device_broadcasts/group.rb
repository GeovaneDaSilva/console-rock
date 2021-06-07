module DeviceBroadcasts
  # Publish call to clients connected via websocket which belong to a group
  class Group
    def initialize(group, message)
      @group = group
      @message = message
    end

    def call
      return unless @group

      query = @group.device_query.recently_connected.page(0).per(100)

      until query.current_page > query.total_pages
        query.each { |device| DeviceBroadcasts::Device.new(device.id, @message, true).call }

        query = @group.device_query.recently_connected.page(query.current_page + 1).per(100)
      end
    end
  end
end
