module Reports
  module OfficeUsersMfa
    # Office 365 2FA list as XLSX
    class XlsxReporter < Base
      private

      def report_class
        Reports::XlsxReporter
      end
    end
  end
end
