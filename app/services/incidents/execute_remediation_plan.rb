# :nodoc
module Incidents
  # :nodoc
  class ExecuteRemediationPlan
    def initialize(remediation_plan_id)
      @remediation_plan = RemediationPlan.find(remediation_plan_id)
    rescue ActiveRecord::RecordNotFound
      Rails.logger.error("Failed to find Remediation Plan #{remediation_plan_id}")
      @remediation_plan = nil
    end

    def call
      return if @remediation_plan.nil?

      @remediation_plan.remediations.where(active: true).update_all(status: :in_progress)

      @remediation_plan.remediations.each do |remediation|
        next unless remediation.active

        ServiceRunnerJob.perform_later(
          "DeviceBroadcasts::Device",
          remediation.target_id,
          remediation.actions.to_json,
          true
        )
      end
    end
  end
end
