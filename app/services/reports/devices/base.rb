module Reports
  module Devices
    # Base devices reporter
    class Base
      def initialize(key, account, opts = nil)
        @key = key
        devices = account.all_descendant_devices
        opts = JSON.parse(opts) if opts.is_a? String
        devices = apply_filters(devices, opts["filters"]) if opts&.key? "filters"
        @collection = devices.order("updated_at DESC")
        @opts = opts
      end

      def call
        report_class.new(@key, @collection, @opts).call
      end

      private

      def apply_filters(devices, filters)
        devices = devices.basic_search(filters["filter"]) if filters["filter"].present?

        if filters["start_date"].present?
          devices = devices.where("last_connected_at >= ?", start_date(filters["start_date"]))
        end

        if filters["end_date"].present?
          devices = devices.where("last_connected_at <= ?", end_date(filters["end_date"]))
        end

        filters.each do |k, v|
          devices = devices.public_send(k.remove("_only")) if k.include?("_only") && v =~ /(true|t|yes|y|1)$/i
        end

        devices
      end

      def start_date(date)
        formatted_date = Time.strptime(date, "%m/%d/%Y")
        formatted_date.to_datetime.beginning_of_day
      end

      def end_date(date)
        formatted_date = Time.strptime(date, "%m/%d/%Y")
        formatted_date.to_datetime.end_of_day
      end

      def report_class
        raise NotImplementedError
      end
    end
  end
end
