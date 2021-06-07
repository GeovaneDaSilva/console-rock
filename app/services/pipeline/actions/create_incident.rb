module Pipeline
  module Actions
    # Creates generic incident from app result(s)
    class CreateIncident
      def initialize(_message, rule_id, app_result_ids, template_id = nil, reset_time = nil, fields = nil)
        @rule_id     = rule_id
        @template_id = template_id
        @reset_time  = reset_time&.to_i || 24
        @fields      = Array(fields)
        @app_results = ::Apps::Result.find(app_result_ids)
        @app_results = [@app_results] unless @app_results.is_a?(Array)
        @account_path = @app_results.first&.account_path
        calculate_values
      rescue ActiveRecord::RecordNotFound
        @app_results = nil
        Rails.logger.error("Failed to create incident for app result #{app_result_ids}")
      end

      def call
        return if @app_results.blank?

        incident = aggregate_app_results || make_incident
        if incident.save
          return if incident.published_at

          # rubocop:disable Layout/LineLength
          Rails.cache.write(["logic-rule-details", @rule_id, @account_path, @values], [@app_results.first["details"], incident.id], expires_in: @reset_time.hours - 5.minutes)
          # rubocop:enable Layout/LineLength
          incident.published!
          ::Incidents::Integrations.create_ticket(incident)
          return
        end

        Rails.logger.error("Incident save failure for autoincident with #{@app_results.to_json}")
      end

      private

      def make_incident
        path = @app_results.first&.account_path
        title, description, remediation = make_incident_parts

        Apps::Incident.new(
          account_path:  path,
          results:       @app_results,
          title:         title,
          description:   description,
          remediation:   remediation,
          logic_rule_id: @rule_id,
          creator:       User.find_by(email: "dolivaw@rocketcyber.com") || User.first
        )
      end

      def make_incident_parts
        Pipeline::Helpers::GenerateIncidentFields.incident_values(@app_results, @template_id)
      end

      def aggregate_app_results
        return if read_result_details.nil?

        if matching_fields?
          Apps::Incident.find(read_result_details.last).tap { |i| i.results.concat(@app_results) }
        end
      rescue ActiveRecord::RecordNotFound
        false
      end

      # calls values so that @values gets populated
      def read_result_details
        @read_result_details ||= Rails.cache.read(["logic-rule-details", @rule_id, @account_path, @values])
      end

      def calculate_values
        return @values unless @values.nil?

        new_details = @app_results.first["details"]
        @values = {}

        @fields.each do |field|
          keys = field.strip.split(".")
          new_value = new_details.dig(*keys)
          @values[field] = new_value
        end
        @values
      end

      def matching_fields?
        old_details = read_result_details.first

        @fields.each do |field|
          keys = field.strip.split(".")
          return false unless @values[field] == old_details.dig(*keys)
        end
        true
      end
    end
  end
end
