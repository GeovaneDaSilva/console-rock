# :nodoc
module DnsFilter
  # :nodoc
  module SaveTemplates
    # :nodoc
    class UserInfo
      def initialize(credential, data = {})
        @credential = credential
        @data       = data
      end

      def call
        return if @data.blank? || @data["user"].blank?

        user_id       = @data.dig("user", "id")
        organizations = @data.dig("organizations").map do |org|
          [org["name"], org["id"]]
        end.to_h

        params = { dns_filter_user_id: user_id, organizations: organizations }
        @credential.update(params)
      end
    end
  end
end
