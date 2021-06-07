module Reports
  module Devices
    module Triage
      # App results as XLSX
      class XlsxReporter < Reports::Devices::Triage::Base
        private

        def report_class
          Reports::XlsxReporter
        end
      end
    end
  end
end
