require "httpi"
require "ms_graph/errors"

# :nodoc
module MsGraph
  # :nodoc
  class CredentialUpdater
    include ErrorHelper

    TOKEN_CALL = "https://login.microsoftonline.com/common/oauth2/v2.0/token".freeze

    def call(cred)
      return "" if cred.nil?

      expiry = Time.zone.at((cred.expiration || Time.zone.now) - 5.minutes)
      if Time.zone.now > expiry
        # Token expired, refresh
        @cred = cred
        refresh_token
      else
        cred.access_token
      end
    end

    private

    def app_permissions_request
      request = HTTPI::Request.new
      request.url = "https://login.microsoftonline.com/#{@cred.tenant_id}/oauth2/v2.0/token"
      client_id = I18n.locale == :barracudamsp ? ENV["BARRACUDA_AZURE_APP_ID"] : ENV["AZURE_2FA_APP_ID"]
      client_secret = I18n.locale == :barracudamsp ? ENV["BARRACUDA_MS_SECRET"] : ENV["AZURE_2FA_APP_SECRET"]

      body = {
        client_id:     client_id,
        grant_type:    "client_credentials",
        client_secret: client_secret,
        scope:         "https://graph.microsoft.com/.default"
      }
      request.body = body
      request
    end

    def delegated_permissions_request
      request = HTTPI::Request.new
      request.url = TOKEN_CALL
      body = {
        client_id:     ENV["AZURE_APP_ID"],
        grant_type:    "refresh_token",
        redirect_uri:  Rails.application.routes.url_helpers.auth_callback_url(host: "https://#{ENV['HOST']}"),
        scope:         ENV["AZURE_SCOPES"],
        refresh_token: @cred.refresh_token,
        client_secret: ENV["AZURE_APP_SECRET"]
      }
      request.body = body
      request
    end

    def refresh_token
      token_request = if @cred.refresh_token.nil?
                        app_permissions_request
                      else
                        delegated_permissions_request
                      end

      begin
        resp = HTTPI.post(token_request)
      rescue Errno::ECONNRESET
        raise MsGraph::ConnectionPeerResetError
      end

      return "" if html_error(__FILE__, resp, @cred.customer_id)

      save(resp)
    end

    def save(resp)
      data = JSON.parse(resp.raw_body)

      unless @cred.refresh_token.nil?
        @cred.update(access_token: data["access_token"], refresh_token: data["refresh_token"],
          expiration: Time.zone.now + data["expires_in"])
      end

      data["access_token"]
    end
  end
end
