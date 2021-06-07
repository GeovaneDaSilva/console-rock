module Api
  module V1
    # endpoint to show life (target for still alive?  pings)
    class HealthcheckController < Api::V1::BaseController
      def index
        head :ok
      end
    end
  end
end
