module Reports
  module Incidents
    # App results as XLSX
    class XlsxReporter < Base
      private

      def report_class
        Reports::XlsxReporter
      end
    end
  end
end
