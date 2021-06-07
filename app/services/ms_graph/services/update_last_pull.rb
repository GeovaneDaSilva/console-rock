# :nodoc
module MsGraph
  # :nodoc
  module Services
    # :nodoc
    class UpdateLastPull
      def initialize(customer_id, app_id, time)
        @customer_id = customer_id
        @app_id = app_id
        @time = time.to_datetime
        @acc_app = AccountApp.where(account_id: customer_id, disabled_at: nil,
          app_id: app_id).where.not(enabled_at: nil).first
      end

      def call
        if @acc_app.nil?
          # Rails.logger.tagged("UpdateLastPull") do
          #   Rails.logger.warn("account app=#{@acc_app.id}")
          # end
          nil
        else
          # this requires ordering the customer's results.  Don't do every time
          @acc_app.update(last_pull: @time)
        end
      end
    end
  end
end
