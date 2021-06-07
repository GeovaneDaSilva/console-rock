module Reports
  module Firewalls
    # Base firewalls reporter
    class Base
      def initialize(key, account, opts = nil)
        @key = key
        firewalls = account.all_descendant_billable_instances.firewall
        opts = JSON.parse(opts) if opts.is_a? String
        if opts.dig("filters", "firewall_filter").present?
          firewalls = apply_filters(firewalls, opts["filters"])
        end
        @collection = firewalls.order("updated_at DESC")
        @opts = opts
      end

      def call
        report_class.new(@key, @collection, @opts).call
      end

      private

      def apply_filters(firewalls, filters)
        vals = []
        where_str = %w[type mac ip device_id].collect do |t|
          vals << filters.dig("firewall_filter")
          " details->>'#{t}' = ? "
        end.join("OR")
        firewalls.where(where_str, *vals)
      end

      def report_class
        raise NotImplementedError
      end
    end
  end
end
