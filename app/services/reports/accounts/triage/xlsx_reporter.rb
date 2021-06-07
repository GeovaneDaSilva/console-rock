module Reports
  module Accounts
    module Triage
      # App results as XLSX
      class XlsxReporter < Base
        private

        def report_class
          Reports::XlsxReporter
        end
      end
    end
  end
end
