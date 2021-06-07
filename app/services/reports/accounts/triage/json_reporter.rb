module Reports
  module Accounts
    module Triage
      # App results as JSON
      class JsonReporter < Base
        private

        def report_class
          Reports::JsonReporter
        end
      end
    end
  end
end
