# Firewalls
class FirewallsController < AuthenticatedController
  def destroy
    authorize current_account, :can_delete_firewalls?

    firewall.destroy if firewall&.line_item_type == "firewall"
    ServiceRunnerJob.perform_later("UpdateReports::BillableInstance", [firewall.id])

    redirect_back fallback_location: root_url
  end

  private

  def firewall
    @firewall ||= current_account.all_descendant_billable_instances.find_by(id: params[:id])
  end
end
