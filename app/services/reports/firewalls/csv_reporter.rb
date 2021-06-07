module Reports
  module Firewalls
    # Device list as CSV
    class CsvReporter < Base
      private

      def report_class
        Reports::CsvReporter
      end
    end
  end
end
