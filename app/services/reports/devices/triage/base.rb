module Reports
  module Devices
    module Triage
      # Base app results reporter
      class Base
        def initialize(key, device, opts = nil)
          @key = key
          @device = device
          @opts = opts
          @collection = filtered_app_results
        end

        def call
          report_class.new(@key, @collection, @opts).call
          self
        end

        private

        def filters
          opts = JSON.parse(@opts)
          opts.fetch("filters", {})
        end

        def app_results
          @device.app_results
        end

        def filtered_app_results
          return app_results.where(id: filters["app_result_id"]) if filters["app_result_id"]

          results = app_results.without_incident
          results = results.where(app_id: filters["app_id"]) if filters["app_id"]
          results = results.where("detection_date >= ?", filters["start_date"]) if filters["start_date"]
          results = results.where("detection_date <= ?", end_date) if filters["end_date"]
          if filters["search"].present?
            results = results.details_ilike(filters["search"].gsub(/\\/, "\\\\\\"))
          end
          results
        end

        def end_date
          filters["end_date"].to_datetime.end_of_day if filters["end_date"]
        end

        def report_class
          raise NotImplementedError
        end
      end
    end
  end
end
