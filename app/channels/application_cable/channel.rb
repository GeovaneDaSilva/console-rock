module ApplicationCable
  # :nodoc
  class Channel < ActionCable::Channel::Base
    include Pundit

    def subscribed
      redis.del(channel_name) if redis.get(channel_name).to_i.negative?
      Rails.logger.debug("Channel #{channel_name} has #{redis.incr(channel_name)} connections")
      redis.expire(channel_name, 5.minutes)
    end

    def unsubscribed
      Rails.logger.debug(
        "Channel #{channel_name} has #{redis.decr(channel_name)} connections"
      )
      redis.del(channel_name) if redis.get(channel_name).to_i.negative?
    end

    def refresh
      redis.set(channel_name, 1) unless redis.get(channel_name).to_i.positive?
      redis.expire(channel_name, 5.minutes) # Extend expiration
    end

    private

    def redis
      Rails.configuration.redis
    end

    def channel_name
      raise NotImplementedError
    end

    def authorize(*args)
      super
    rescue Pundit::NotAuthorizedError
      reject
    end
  end
end
