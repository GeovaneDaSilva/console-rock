module DeviceBroadcasts
  # Base class for broadcasting to devices
  class Base
    def self.redis_pool
      @@redis_pool ||= ConnectionPool.new(size: 5, timeout: 5) do
        Redis.new(url: ENV.fetch("WS_REDIS_URL", ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/0")))
      end
    end

    private

    def redis_pool
      self.class.redis_pool.with do |conn|
        yield conn
      end
    end
  end
end
