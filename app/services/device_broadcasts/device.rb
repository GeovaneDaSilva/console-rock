module DeviceBroadcasts
  # Publish call to clients connected via websocket with a given device fingerprint
  class Device < Base
    def initialize(fingerprint, message, persistent = false)
      @fingerprint = fingerprint
      @message     = message
      @persistent  = persistent
    end

    def call
      # Rails.logger.tagged("DeviceBroadcasts::Device") do
      #   Rails.logger.warn(
      #     "device_id=#{@fingerprint} message=#{@message}"
      #   )
      # end

      redis_pool do |redis|
        if @persistent
          length = redis.llen(queue_key)

          redis.lpop(queue_key) if length >= ENV.fetch("MAX_DEVICE_QUEUE_LENGTH", 10)
          redis.rpush(queue_key, @message) unless message_exists?(redis)
          redis.publish("trigger.queue.device", @fingerprint)
        else
          redis.publish("device", { target: @fingerprint, payload: @message }.to_json)
        end
      end

      true
    end

    private

    def message_exists?(redis)
      redis.lrange(queue_key, 0, -1).to_a.include?(@message)
    end

    def queue_key
      @queue_key ||= "queue.device.#{@fingerprint}"
    end
  end
end
