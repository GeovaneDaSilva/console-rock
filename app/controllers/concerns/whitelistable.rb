# :nodoc
module Whitelistable
  extend ActiveSupport::Concern

  included do
    helper_method :whitelist_options, :whitelist_path, :account, :source_page
  end

  def show
    authorize scope, :triage?
    authorize([:accounts, app], :whitelistable?)

    render "triage/whitelists/show"
  end

  def create
    authorize scope, :triage?

    respond_to do |format|
      format.js do
        @job_id = PolledTaskRunner.new.call(
          "Apps::Results::Whitelister", app, scope, params.permit!
        ).key.split("/").last

        @result_path = source_page
        render "triage/whitelists/create"
      end
    end
  end

  private

  def source_page
    incident? ? account_apps_incident_path({ id: params[:incident_id] }) : triage_path(query_params)
  end

  def incident?
    params[:incident_id].present?
  end

  def incident
    return nil unless incident?

    @incident ||= Apps::Incident.find(params[:incident_id])
  end

  # Get all:limit(100) the possible whitelist options from selected app results
  # Dedupe values and merge into one hash
  def whitelist_options
    return @whitelist_options if defined?(@whitelist_options)

    @whitelist_options = {}.with_indifferent_access
    all_whitelistable_options = selected_app_results.limit(100).collect(&:whitelistable_options)

    all_whitelistable_options.each do |whitelist_option|
      whitelist_option.each do |key, values| # { "Key" => Set }
        @whitelist_options[key] ? @whitelist_options[key] += values : @whitelist_options[key] = values
      end
    end

    @whitelist_options
  end

  def app_whitelist_config
    APP_WHITELISTS.dig(app.configuration_type)
  end

  def app_whitelist_klass
    app.configuration_type.classify.to_s.constantize
  end
end
