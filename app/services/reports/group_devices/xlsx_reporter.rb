module Reports
  module GroupDevices
    # Xlsx group devices reporter
    class XlsxReporter < Base
      private

      def report_class
        Reports::XlsxReporter
      end
    end
  end
end
