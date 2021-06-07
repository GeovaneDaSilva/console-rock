module Reports
  module Accounts
    module Triage
      # App results as CSV
      class CsvReporter < Base
        private

        def report_class
          Reports::CsvReporter
        end
      end
    end
  end
end
