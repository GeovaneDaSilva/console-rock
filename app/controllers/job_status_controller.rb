# Fetch job status
class JobStatusController < AuthenticatedController
  def show
    authorize(current_user, :fetch_job_status?)
    status = ActiveJob::Status.get(job_params[:job_id])
    render json: status.to_json
  end

  private

  def job_params
    params.permit(:job_id)
  end
end
