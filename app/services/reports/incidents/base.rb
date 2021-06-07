module Reports
  module Incidents
    # Base devices reporter
    class Base
      def initialize(key, account, incident, opts = {})
        @key = key
        @account = account

        @collection = incident.is_a?(Apps::Incident) ? incident.results.order("updated_at DESC") : incident
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
