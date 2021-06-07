module DeviceMessages
  # Evaluate if the indicator is a threat
  class ThreatEvaluation < Base
    include ::ApiClients::ApiLimits::VirusTotal

    TYPE_EVALUATION = {
      hash: Threats::Evaluation::Hash, ip: Threats::Evaluation::Ip,
      url: Threats::Evaluation::Url, hash2: Threats::Evaluation::Hash
    }.with_indifferent_access

    def call
      ServiceRunnerJob.set(
        queue: "threat_evaluation"
      ).perform_later(
        TYPE_EVALUATION[threat_evaluation].name, device,
        threat_value, payload.fetch("meta", {}).to_json
      )
    end

    private

    def threat_evaluation
      @threat_evaluation ||= TYPE_EVALUATION.keys.find do |key|
        payload.dig(key).present?
      end
    end

    def threat_value
      @threat_value ||= payload.dig(threat_evaluation)
    end

    def api_key
      ENV["VIRUS_TOTAL_API_KEY"]
    end
  end
end
