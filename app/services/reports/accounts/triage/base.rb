module Reports
  module Accounts
    module Triage
      # Base account app results reporter
      class Base
        def initialize(key, account, opts = nil)
          @key = key
          @account = account
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

        # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength
        def app_results
          if filters["app_id"]
            app = App.find(filters["app_id"])
            if app.is_a?(Apps::DeviceApp)
              @account.all_descendant_device_app_results.includes(:customer, :device)
            elsif app.is_a?(Apps::PasslyApp)
              @account.all_descendant_passly_results.includes(:customer)
            elsif app.is_a?(Apps::IronscalesApp)
              @account.all_descendant_ironscales_results.includes(:customer)
            elsif app.is_a?(Apps::DeepInstinctApp)
              @account.all_descendant_deep_instinct_results.includes(:customer)
            elsif app.is_a?(Apps::BitdefenderApp)
              @account.all_descendant_bitdefender_results.includes(:customer)
            elsif app.is_a?(Apps::HibpApp)
              @account.all_descendant_hibp_results.includes(:customer)
            elsif app.is_a?(Apps::Office365App)
              @account.all_descendant_office365_results.includes(:customer)
            elsif app.is_a?(Apps::WebrootApp)
              @account.all_descendant_webroot_results.includes(:customer)
            elsif app.is_a?(Apps::SentineloneApp)
              @account.all_descendant_sentinelone_results.includes(:customer)
            elsif app.is_a?(Apps::CylanceApp)
              @account.all_descendant_cylance_results.includes(:customer)
            elsif app.is_a?(Apps::CloudApp)
              @account.all_descendant_cloud_app_results.includes(:customer)
            else
              @account.all_descendant_app_results
            end
          else
            @account.all_descendant_app_results
          end
        end
        # rubocop:enable Metrics/CyclomaticComplexity,Metrics/MethodLength

        def filtered_app_results
          return app_results.where(id: filters["app_result_id"]) if filters["app_result_id"]

          results = app_results.without_incident
          results = results.where(app_id: filters["app_id"]) if filters["app_id"]
          results = results.where("detection_date >= ?", start_date) if start_date
          results = results.where("detection_date <= ?", end_date) if end_date
          if filters["search"].present?
            results = results.details_ilike(filters["search"].gsub(/\\/, "\\\\\\"))
          end
          results
        end

        def report_class
          raise NotImplementedError
        end

        def start_date
          return @start_date unless @start_date.nil?

          time = Time.strptime(filters["start_date"], "%m/%d/%Y")
          @start_date ||= time.to_datetime.beginning_of_day
        rescue ArgumentError, TypeError
          nil
        end

        def end_date
          return @end_date unless @end_date.nil?

          time = Time.strptime(filters["end_date"], "%m/%d/%Y")
          @end_date ||= time.to_datetime.end_of_day
        rescue ArgumentError, TypeError
          nil
        end
      end
    end
  end
end
