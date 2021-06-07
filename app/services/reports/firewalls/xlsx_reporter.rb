module Reports
  module Firewalls
    # Device list as XLSX
    class XlsxReporter < Base
      private

      def report_class
        Reports::XlsxReporter
      end
    end
  end
end
