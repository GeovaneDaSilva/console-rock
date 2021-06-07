# :nodoc
module Incidents
  # :nodoc
  class UpdateRemediation
    include ErrorHelper

    def initialize(params)
      # remember that find_by will return nil if there is no entry
      @remediation_plan = RemediationPlan.find_by(incident_id: params[:incident_id])
      @params = params
      @account_path = Apps::Result.find(@params[:app_results].first).account_path
    rescue ActiveRecord::RecordNotFound, NoMethodError
      @account_path = nil
    end

    def call
      return if @account_path.nil? || @params[:incident_id].nil? || @params[:app_results].blank?

      create_remediation_plan if @remediation_plan.nil?

      return if database_error(__FILE__, @remediation_plan)

      @params[:app_results].each do |result_id|
        ServiceRunnerJob.perform_later("Incidents::GenerateRemediation", result_id, @remediation_plan.id)
      end
    end

    private

    def create_remediation_plan
      @remediation_plan = RemediationPlan.new(
        account_path: @account_path,
        incident_id:  @params[:incident_id]
      )
      @remediation_plan.save
    end
  end
end
