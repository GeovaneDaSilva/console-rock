module Reports
  module Devices
    module Triage
      # App results as CSV
      class CsvReporter < Reports::Devices::Triage::Base
        private

        def report_class
          Reports::CsvReporter
        end
      end
    end
  end
end
