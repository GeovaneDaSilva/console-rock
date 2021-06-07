module Administration
  # Admin views for crash reports
  class CrashReportsController < BaseController
    include Pagy::Backend

    before_action :user, only: %i[edit update]

    def index
      authorize(:administration, :view_crash_reports?)
      query = CrashReport.includes(:upload, device: [:customer]).order("created_at DESC")

      query = query.where(device_id: params[:device_id].downcase) if params[:device_id].present?

      @pagination, @crash_reports = pagy query, items: 20
    end

    def destroy
      authorize(:administration, :manage_crash_reports?)

      if crash_report.destroy
        flash[:notice] = "Crash report deleted"
      else
        flash[:error] = "Problem deleting crash report"
      end

      redirect_back fallback_location: root_path
    end

    private

    def crash_report
      @crash_report ||= CrashReport.find(params[:id])
    end
  end
end
