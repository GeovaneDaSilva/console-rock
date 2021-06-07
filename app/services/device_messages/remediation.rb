module DeviceMessages
  # Isolate or Un-Isolate a device
  class Remediation < Base
    def call
      payload = @message.dig("payload")
      if payload.blank? || payload.nil?
        Rails.logger.error("Remediation - invalid payload #{@message}")
        return
      end

      remediation = ::Remediation.find(payload["id"])

      update_remediation(payload, remediation)

      Broadcasts::Remediations::Status.new(remediation).call
    rescue ActiveRecord::RecordNotFound
      Rails.logger.error("Remediation save failed #{@message}")
    end

    private

    def update_remediation(payload, remediation)
      case payload["status"]
      when "success"
        remediation.update(status: :complete, status_detail: DateTime.current.to_s)
        # if remediation.remediation_plan.remediations.pluck(:status).all? { |status| status == "complete" }
        #   Apps::Incident.find_by(remediation_plan: remediation.remediation_plan)&.update(state: :resolved)
        # end
        Rails.logger.info("Remediation success - id: #{payload['id']}")
      when "failure"
        fail_point = remediation.actions.dig("payload", "remediation_actions")&.map do |item|
          if item["order"] == Integer(payload.dig("fail_point"))
            "#{item.dig('action')} #{item.dig('file_path') || item.dig('key')}"
          end
        end&.compact&.first
        fail_point ||= "defender full scan" if remediation.actions.dig("payload", "defender_full_scan")
        remediation.update(status: :failed, status_detail: fail_point)
        Rails.logger.warn("Remediation failed - id: #{payload['id']}")
      else
        Rails.logger.error("Remediation - unsupported status #{@message}")
      end
    end
  end
end
