# :nodoc
module Incidentable
  extend ActiveSupport::Concern

  include Pagy::Backend

  class RemediationPlanSaveException < StandardError; end

  included do
    helper_method :incident_path, :existing_incidents, :targeted_app_results,
                  :open_incidents, :resolved_incidents
  end

  def show
    authorize scope, :create_incidents?

    @incident = Apps::Incident.new(
      account_path: selected_app_results.first.account_path, results: targeted_app_results
    )

    @open_incidents_pagination, @open_incidents = pagy open_incidents, page_param: :open_incidents, items: 10
    @resolved_incidents_pagination, @resolved_incidents = pagy(
      resolved_incidents, page_param: :resolved_incidents, items: 10
    )

    render "triage/incidents/show"
  end

  def create
    authorize scope, :create_incidents?

    if params[:commit].parameterize == "add"
      add_to_incident!
    else
      create_new_incident!
    end
  end

  private

  def add_to_incident!
    @incident = existing_incidents.find(params.dig("apps_incident", "id"))
    @incident.reopen

    results = selected_app_results.where(account_path: @incident.results.first.account_path)
    @incident.results << results

    Apps::Result.transaction do
      if @incident.save
        publish! if params[:publish_immediately] == "true"
        flash[:notice] = "Results added to incident ##{@incident.id}"
        save_remediations
        decrement_counters(results.pluck(:id))
        redirect_to triage_path
      else
        flash.now[:error] = "Unable to add to incident"
        render "triage/incidents/show"
      end
    end
  end

  def create_new_incident!
    results = selected_app_results.where(account_path: selected_app_results.first.account_path)

    @incident = Apps::Incident.create(
      incident_params.merge(
        account_path: selected_app_results.first.account_path, creator: current_user,
        results: results
      )
    )

    Apps::Result.transaction do
      if @incident.save
        publish! if params[:publish_immediately] == "true"
        flash[:notice] = "Incident ##{@incident.id} created"
        save_remediations(true)
        decrement_counters(results.pluck(:id))
        redirect_to triage_path
      else
        flash.now[:error] = "Unable to create incident"
        render "triage/incidents/show"
      end
    end
  end

  def publish!
    return if @incident.published?

    @incident.published!

    ::Incidents::Integrations.create_ticket(@incident)
  end

  def incident_params
    params.require(:apps_incident).permit(
      :title, :description, :remediation
    )
  end

  def existing_incidents
    account.all_descendant_incidents
           .where(account_path: targeted_app_results.first.account_path)
           .order("state DESC, updated_at DESC")
  end

  def open_incidents
    existing_incidents.open
  end

  def resolved_incidents
    existing_incidents.resolved
  end

  # Only allow targeting of app results which belong to the same account
  def targeted_app_results
    selected_app_results.where(account_path: selected_app_results.first.account_path)
                        .page(0).per(10)
  end

  def save_remediations(new_record = false)
    remediation_plan = nil
    if new_record
      remediation_plan = generate_remediation_plan
      raise RemediationPlanSaveException unless remediation_plan.save
    else
      remediation_plan = RemediationPlan.find_by(incident_id: @incident.id)
    end
    return if remediation_plan.nil?

    ServiceRunnerJob.perform_later(
      "Incidents::UpdateRemediation",
      {
        app_results: params[:app_results],
        incident_id: @incident.id
      }
    )
  end

  def generate_remediation_plan
    RemediationPlan.new(
      account_path: @incident.account_path,
      incident_id:  @incident.id
    )
  end

  def decrement_counters(results = [])
    ServiceRunnerJob.perform_later("Apps::Results::UpdateCounterCaches", "decrement", results)
  end
end
