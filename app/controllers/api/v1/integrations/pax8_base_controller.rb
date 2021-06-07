module Api
  module V1
    module Integrations
      # Base controller for all V2 API calls
      class Pax8BaseController < Api::V1::BaseController
        before_action :authenticate

        private

        def authenticate
          authenticate_token || error_message
        end

        def authenticate_token
          authenticate_with_http_token do |token, _options|
            @api_key = ApiKey.find_by(access_token: token)

            !@api_key.nil?
          end
        end

        def account
          @account ||= Account.find_by(id: @api_key.account_id)
        end

        def error_message
          if @api_key.nil?
            render json: { code: 40_101, details: "Invalid credential" }, status: :unauthorized
          elsif @api_key.expiration < DateTime.current
            render json: { code: 40_102, details: "Expired credential" }, status: :unauthorized
          end
        end
      end
    end
  end
end
