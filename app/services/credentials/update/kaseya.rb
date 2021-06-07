module Credentials
  module Update
    # Update Kaseya PSA credential (i.e. get access token)
    class Kaseya
      include HttpHelper
      include ErrorHelper

      def initialize(credential)
        @credential = credential
      end

      def call
        return unless @credential.is_a?(Credentials::Kaseya)

        if @credential.expiration > 5.minutes.from_now
          @credential.access_token
        else
          refresh_access_token
        end
      end

      private

      def refresh_access_token
        url = "#{@credential.base_url}/api/token"
        body = {
          grant_type: "password",
          username:   @credential.kaseya_username,
          password:   @credential.kaseya_password,
          tenant:     @credential.kaseya_tenant
        }
        headers = {
          "content-type" => "application/x-www-form-urlencoded",
          "accept"       => "application/json"
        }

        response = make_api_call(url, headers, {}, body, "post")
        return if html_error(__FILE__, response, @credential.account_id.to_s)

        data = JSON.parse(response.raw_body)
        save(data)
      end

      def save(response)
        @credential.update(
          access_token: response["access_token"],
          expiration:   DateTime.current + response["expires_in"].seconds,
          token_type:   response["token_type"]
        )
        response["access_token"]
      end
    end
  end
end
