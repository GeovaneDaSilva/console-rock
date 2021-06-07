# Shared methods for reporting a group of devices
module GroupReportable
  private

  def group
    params[:group_id].present? ? ::Group.find(params[:group_id]) : ::Group.new(new_group_params)
  end

  def new_group_params
    group_params.merge(account: current_account)
  end

  def group_params
    params.require(:group).permit(
      :name, :query, :network, :os, :public_ip, :family_version_and_edition,
      query_fields: []
    )
  rescue ActionController::ParameterMissing
    { query_fields: ::Group.values_for_query_fields }
  end
end
