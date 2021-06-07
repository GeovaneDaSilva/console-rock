# Authorization for Devices objects
class DevicePolicy < ApplicationPolicy
  def show?
    incident_responder?
  end

  def destroy?
    incident_responder?
  end

  def purge?
    omnipotent?
  end

  def defender_enabled?
    defender_app && Accounts::AppPolicy.new(record.customer, defender_app).runnable?
  end

  def defender_action?
    incident_responder?
  end

  def agent_triage?
    omnipotent?
  end

  def memory_dump?
    omnipotent?
  end

  def triage?
    incident_responder?
  end

  def create_incidents?
    soc_operator? || omnipotent?
  end

  def create_logic_rules?
    soc_operator? || omnipotent?
  end

  def update_inventory?
    incident_responder?
  end

  def app_action?
    editor?
  end

  def realtime_logs?
    admin_config = record.customer.setting.admin_config

    admin_config.dig("enable_console_log").present? ||
      admin_config.dig("enable_console_log:#{record.hostname}").present?
  end

  def view_devices?
    incident_responder?
  end

  private

  def role_accounts
    Account.where("path @> ?", record.customer.path)
  end

  def defender_app
    @defender_app ||= App.where(configuration_type: :defender).first
  end
end
