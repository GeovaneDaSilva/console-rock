# :nodoc
module Sentinelone
  # :nodoc
  module SaveTemplates
    # :nodoc
    class UserInfo
      def initialize(_app_id, cred, event)
        @cred   = cred
        @event  = event
      end

      def call
        return if @event.blank?

        @cred.update(
          email:      @event.dig("email"),
          expiration: @event.dig("apiToken", "expiresAt").to_datetime
        )
      end
    end
  end
end
