module Reports
  module Devices
    module Triage
      # App results as JSON
      class JsonReporter < Reports::Devices::Triage::Base
        private

        def report_class
          Reports::JsonReporter
        end
      end
    end
  end
end
