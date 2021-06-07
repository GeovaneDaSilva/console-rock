module Api
  module V1
    module Accounts
      # Account stats
      # Relies on cookie authentication
      class StatsController < AuthenticatedController
        def show
          authorize account

          render json: stats
        end

        private

        def stats
          ::Accounts::StatsToJson.new(account).call
        end

        def account
          @account ||= Account.find(params[:account_id])
        end
      end
    end
  end
end
