# :nodoc
module Triagable
  include TriageScopeable
  include TriageExportable
  extend ActiveSupport::Concern

  included do
    before_action :app_required!

    helper_method :app, :app_results, :similar_detections, :start_date, :end_date, :query_params,
                  :triage_path, :filtered_app_results, :app_counter_caches,
                  :total_count, :paginate_similar_detections
  end

  private

  def app_required!
    return if params[:app_id].present?

    app = app_results.first&.app

    if app.nil?
      flash[:notice] = "No results to review"
      redirect_back fallback_location: fallback_location
    else
      redirect_to triage_path(app_id: app.id)
    end
  end

  def app
    @app ||= App.find(params[:app_id])
  end

  def query_params
    {
      start_date: params[:start_date], end_date: params[:end_date], search: params[:search],
      app_id: params[:app_id]
    }.reject { |_k, v| v.blank? }
  end

  # def other_apps
  #   App.enabled.select do |app|
  #     account.all_descendant_app_results.without_incident.where(app: app).any?
  #   end
  # end

  def account
    raise NotImplementedError
  end

  def triage_path(*_opts)
    raise NotImplementedError
  end

  def fallback_location
    raise NotImplementedError
  end
end
