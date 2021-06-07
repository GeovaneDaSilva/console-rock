module R
  # Account breaches
  class ExecutiveSummariesController < BaseController
    extend Lettable
    include AccountStatsable
    include Pagy::Backend

    layout "reports"

    let(:report) { :executive_summary }
    let(:title) { "Executive Summary" }
    let(:time_range_enabled) { true }
    let(:start_date) { params[:start_date].present? ? Time.zone.parse(params[:start_date]) : 1.month.ago }
    let(:end_date) { params[:end_date].present? ? Time.zone.parse(params[:end_date]) : start_date + 1.month }
    let(:account) { params[:account] ? Account.find(params[:account]) : current_account }

    let(:render_customer_list) { account.provider? }

    let(:start_time) { start_date.beginning_of_day }
    let(:end_time) { end_date.end_of_day }
    let(:data) { R::ExecutiveSummaryQuery.new(account, start_time, end_time) }

    def show
      authorize account, :view_report_executive_summary?
    end
  end
end
