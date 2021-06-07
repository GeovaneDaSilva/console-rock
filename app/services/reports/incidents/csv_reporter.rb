module Reports
  module Incidents
    # Incident list as CSV
    class CsvReporter < Base
      private

      def report_class
        Reports::CsvReporter
      end
    end
  end
end
