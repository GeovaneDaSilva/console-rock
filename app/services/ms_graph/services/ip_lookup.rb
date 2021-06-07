# :nodoc
module MsGraph
  # :nodoc
  module Services
    # :nodoc
    class IpLookup
      def initialize(result)
        @result = result
        tmp = Apps::Config
              .where(app_id: @result.app_id, account_id: @result.customer_id)
              .first

        config = tmp.nil? ? {} : tmp.merged_config
        @excluded_countries = (config.dig("signin_excluded_countries") ||
          APP_CONFIGS[:office365_signin][:signin_excluded_countries])
                              .select { |_key, hash| hash.dig("enabled") }
        @bad_only = config.dig("signin_only_report_bad_reputation_connections") ||
                    APP_CONFIGS[:office365_signin][:signin_only_report_bad_reputation_connections]
      end

      # rubocop:todo Metrics/CyclomaticComplexity
      def call
        return if @result.nil? || @result.details.dig("ipAddress").blank?

        details = @result.details

        badness = Threats::Lookup::Ip.new(details.dig("ipAddress")).call
        threats = []
        verdict = "informational"
        details["location"]["countryOrRegion"] ||= badness.dig("geo_info", "country", "code")&.upcase

        unless badness.nil?
          details["detections"] = badness.dig("lookup_results", "detected_by")
          details["location"]["geoCoordinates"]["latitude"] ||= badness.dig("geo_info", "location", "latitude")
          details["location"]["geoCoordinates"]["longitude"] ||= badness.dig("geo_info", "location", "longitude")
          verdict = details["detections"].nil? || details["detections"] > 1 ? "malicious" : "suspicious"

          if @excluded_countries.include?(details["location"]["countryOrRegion"]) ||
             (@bad_only && details["detections"]&.zero?)
            @result.destroy
            return
          end

          details["location"]["countryOrRegion"] ||= badness.dig("geo_info", "country", "code")

          if @result.value.strip == ","
            @result.assign_attributes(
              value: "#{details['location']['city']}, #{details['location']['countryOrRegion']}"
            )
          end

          (badness.dig("lookup_results", "sources") || []).each do |i|
            threats += i["assessment"].strip.split(" ")
          end
        end

        details["threats"] = threats.to_set.to_a

        @result.assign_attributes(verdict: verdict, details: organized_params(details))
        return unless @result.save

        ServiceRunnerJob.perform_later("Apps::Results::Processor", @result)
        ServiceRunnerJob.perform_later("MsGraph::Services::AddGeocodedThreat", @result)
      rescue Threats::Lookup::ApiLimitExceeded
        ServiceRunnerJob.set(
          queue: :threat_evaluation, wait: SecureRandom.rand(10..120).minutes
        ).perform_later(self.class.name, @result)
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      private

      def organized_params(event)
        filtered_params = {
          "type":       "signin",
          "attributes": {
            "user":          {
              "name":          event["userDisplayName"],
              "principalName": event["userPrincipalName"]
            },
            "location":      {
              "ip_address":      event["ipAddress"],
              "city":            event.dig("location", "city"),
              "state":           event.dig("location", "state"),
              "countryOrRegion": event.dig("location", "countryOrRegion"),
              "threatsFound":    event["threats"],
              "latitude":        event.dig("location", "geoCoordinates", "latitude"),
              "longitude":       event.dig("location", "geoCoordinates", "longitude")
            },
            "threat_detail": {
              "detections":              event["detections"],
              "riskState":               event["riskState"],
              "conditionalAccessStatus": event["conditionalAccessStatus"]
            },
            "device_detail": {
              "appDisplayName": event["appDisplayName"]
            }
          }
        }

        event["deviceDetail"].keys.each do |key|
          if event["deviceDetail"][key].present?
            filtered_params[:attributes][:device_detail][key] = event.dig("deviceDetail", key)
          end
        end

        unless event["status"]["errorCode"].zero?
          filtered_params[:attributes][:user][:status] = event["status"]
        end

        filtered_params[:attributes][:user][:loginAttempt] = if event.dig("status", "errorCode").zero?
                                                               "Success"
                                                             else
                                                               "Failure"
                                                             end
        unless event["riskDetail"] == "none"
          filtered_params[:attributes][:threat_detail][:riskDetail] = event["riskDetail"]
        end
        unless event["riskLevelAggregated"] == "none"
          filtered_params[:attributes][:threat_detail][:riskLevelAggregated] = event["riskLevelAggregated"]
        end
        unless event["riskLevelDuringSignIn"] == "none"
          filtered_params[:attributes][:threat_detail][:riskLevelDuringSignIn] = event["riskLevelDuringSignIn"]
        end

        if event["appliedConditionalAccessPolicies"].present?
          filtered_params[:attributes][:threat_detail][:appliedConditionalAccessPolicies] =
            event["appliedConditionalAccessPolicies"]
        end

        filtered_params
      end
    end
  end
end
