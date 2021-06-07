module Reports
  module OfficeUsersMfa
    # Office 365 2FA list as CSV
    class CsvReporter < Base
      private

      def report_class
        Reports::CsvReporter
      end
    end
  end
end
