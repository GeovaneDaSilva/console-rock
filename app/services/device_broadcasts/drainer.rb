module DeviceBroadcasts
  # Drain queue for to clients connected via websocket with a given device fingerprint
  class Drainer < Base
    def initialize(fingerprint)
      @fingerprint = fingerprint
    end

    def call
      redis_pool do |redis|
        redis.del(queue_key)
      end

      true
    end

    private

    def queue_key
      @queue_key ||= "queue.device.#{@fingerprint}"
    end
  end
end
