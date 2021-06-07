module Reports
  module GroupDevices
    # Csv group devices reporter
    class CsvReporter < Base
      private

      def report_class
        Reports::CsvReporter
      end
    end
  end
end
