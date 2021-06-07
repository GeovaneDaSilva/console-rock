module Reports
  module GroupDevices
    # Base group devices reporter
    class Base
      def initialize(key, group, opts = nil)
        @key = key
        @collection = group.device_query
        @opts = opts
      end

      def call
        report_class.new(@key, @collection, @opts).call
      end

      private

      def report_class
        raise NotImplementedError
      end
    end
  end
end
