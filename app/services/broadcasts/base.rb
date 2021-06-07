module Broadcasts
  # :nodoc
  class Base
    private

    def active_channel?(channel_name)
      Rails.configuration.redis.get(channel_name).to_i.positive?
    end

    def customer_scope
      @account.provider? ? @account.all_descendants : @account
    end
  end
end
