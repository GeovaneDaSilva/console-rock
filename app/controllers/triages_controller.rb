# :nodoc
class TriagesController < AuthenticatedController
  include Triagable

  helper_method :account

  def show
    authorize account, :triage?

    @pagination, @similar_detections = paginate_similar_detections

    if app_results.none?
      flash[:notice] = "No results to review"
      redirect_to fallback_location
    end
  end

  # rubocop:disable Metrics/MethodLength
  def create
    authorize account, :triage?

    respond_to do |format|
      format.js do
        if params[:delete]
          delete_results!
        elsif params[:whitelist]
          whitelist_results!
        elsif params[:incident]
          incident_results!
        elsif params[:logic_rule]
          logic_rule_results!
        elsif params[:export]
          export_results!
        elsif params[:antivirus_actions]
          redirect_to account_antivirus_actions_path(params.permit!.except(:page)), turbolinks: :advance
        elsif params[:override]
          redirect_to account_override_index_path(params.permit!), turbolinks: :advance
        else
          redirect_to triage_path(query_params), turbolinks: :advance
        end
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  private

  def delete_results!
    @job_id = PolledTaskRunner.new.call(
      "Apps::Results::Destroyer", app, account, params.permit!
    ).key.split("/").last

    @result_path = triage_path(query_params)
    render "triages/create"
  end

  def whitelist_results!
    redirect_to account_triage_whitelist_path(
      account, query_params.merge(
                 app_results: params[:app_results], apply_to_all_similar: params[:apply_to_all_similar]
               )
    ), turbolinks: :advance
  end

  def incident_results!
    redirect_to account_triage_incident_path(
      account, query_params.merge(
                 app_results: params[:app_results], apply_to_all_similar: params[:apply_to_all_similar]
               )
    ), turbolinks: :advance
  end

  def logic_rule_results!
    redirect_to account_triage_logic_rule_path(
      account, query_params.merge(app_results: params[:app_results])
    ), turbolinks: :advance
  end

  def export_results!
    @job_id = PolledTaskRunner.new.call(
      report_type, account, download_options
    ).key.split("/").last
    render partial: "shared/download_report"
  end

  def report_type
    case export_type
    when "csv"
      "Reports::Accounts::Triage::CsvReporter"
    # when "xlsx"
    #   "Reports::Accounts::Triage::XlsxReporter"
    when "json"
      "Reports::Accounts::Triage::JsonReporter"
    end
  end

  def app_results
    # This was just DeviceApp and CloudApp (which should work, since all the others are sub-classes
    # of CloudApp).  However, for some reason that neither I nor Daniel could figure out, this consistently
    #  causes problems.
    if app.is_a?(Apps::DeviceApp)
      account.all_descendant_device_app_results.where(app: app).includes(:customer, :device)
    else
      account.all_descendant_app_results.where(app: app).includes(:customer)
    end
  end

  def app_counter_caches
    account.all_descendant_app_counter_caches.where(app: app)
  end

  def account
    Account.find(params[:account_id])
  end

  def fallback_location
    root_path
  end

  def triage_path(*opts)
    account_triage_path(account, *opts)
  end
end
