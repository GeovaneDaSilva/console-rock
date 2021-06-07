module R
  # Account breaches
  class BreachesController < BaseController
    extend Lettable
    include AccountStatsable

    helper_method :devices, :apps, :all_app_results, :ttps, :hunt_results, :top_apps,
                  :top_ctnc_countries, :totals

    let(:report) { :breaches }
    let(:title) { "Cyber Monitoring" }
    let(:render_customer_list) { account.provider? }
    let(:time_range_enabled) { false }

    let(:account_id) { params[:account] }
    let(:account) { account_id ? accounts_scope.find(account_id) : current_account }
    let(:graph_json) { Accounts::StatsToJson.new(account).call }

    def show
      authorize account, :view_cyber_monitoring_report?
    end

    private

    def accounts_scope
      current_account.all_descendant_customers
    end

    def hunt_results
      @hunt_results ||= account.all_descendant_hunt_results
                               .unarchived.positive.includes(:hunt, :device)
    end

    def devices
      @devices ||= account.all_descendant_devices.not_deleted
    end

    def apps
      @apps ||= App.enabled.ga.load
    end

    def all_app_results
      @all_app_results ||= account.all_descendant_app_results
                                  .order("detection_date DESC")
    end

    def ttps
      @ttps ||= TTP.find(ttp_ids)
    end

    def top_apps
      account
        .all_descendant_app_results
        .with_enabled_apps
        .group("apps.title")
        .order(Arel.sql("count(*) DESC"))
        .limit(5)
        .count
    end

    def top_ctnc_countries
      account
        .all_descendant_app_results
        .joins(:app)
        .where(apps: { report_template: :cyberterrorist_network_connection })
        .group("details -> 'attributes' -> 'country'")
        .count
        .sort_by(&:last).reverse
        .take(10)
    end

    def ttp_ids
      apps.where(report_template: :ttp).collect do |app|
        app.app_results
           .where("account_path <@ ?", account.path)
           .order("detection_date DESC")
           .page(params["app_#{app.id}".to_sym])
           .collect(&:details)
           .collect(&:ttp_id)
      end.flatten.uniq.reject(&:blank?)
    end
  end
end
