# :nodoc
module Sentinelone
  # :nodoc
  module SaveTemplates
    # :nodoc
    class DeviceCount
      def initialize(_app_id, cred, event)
        @customer = cred.account
        @event    = event
      end

      def call
        return if @event.blank? || @customer.nil?

        BillableInstance.new(account_path: @customer.path, external_id: external_id,
          details: @event, line_item_type: "sentinelone").save
      end

      private

      def external_id
        "#{@customer.id}-sentinel-#{DateTime.current.year}-#{DateTime.current.yday}"
      end
    end
  end
end
