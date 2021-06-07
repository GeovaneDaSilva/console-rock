module Reports
  module Incidents
    # App results as JSON
    class JsonReporter < Base
      private

      def report_class
        Reports::JsonReporter
      end
    end
  end
end
