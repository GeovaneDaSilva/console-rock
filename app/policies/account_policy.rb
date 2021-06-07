# Policy for acccount objects
class AccountPolicy < ApplicationPolicy
  def add_discreet_apps?
    omnipotent?
  end

  def app_action?
    editor?
  end

  def can_set_uninstall?
    editor?
  end

  def can_set_url?
    omnipotent?
  end

  def can_set_verbosity?
    editor?
  end

  def can_set_offline?
    omnipotent?
  end

  def can_set_super?
    omnipotent?
  end

  def manage_device_isolation?
    editor?
  end

  def can_see_nav?
    # TODO: this is the right permissions right now, but this should not be tied to incident response
    incident_responder?
  end

  def can_set_remediate?
    incident_responder?
  end

  def can_set_polling?
    editor?
  end

  def can_set_user_session_timeout?
    editor?
  end

  def can_set_channel?
    omnipotent?
  end

  def can_set_report_agent_errors?
    editor?
  end

  def can_create_sub_accounts?
    editor? && record.distributor? || omnipotent?
  end

  def can_change_parallel_sub_task_count?
    editor?
  end

  def can_change_file_hash_refresh_interval?
    editor?
  end

  def can_change_app_result_cache_age?
    editor?
  end

  def can_change_max_cpu_usage?
    editor?
  end

  def can_change_max_memory_usage?
    editor?
  end

  def can_change_max_sustained_memory_usage?
    editor?
  end

  def can_change_disk_scan_time?
    editor?
  end

  def can_set_device_expiration?
    editor?
  end

  def can_on_demand_analyze?
    editor? && billing_account&.plan&.on_demand_analysis_types&.any?
  end

  def can_on_demand_hunt?
    editor? && billing_account&.plan&.on_demand_hunt_types&.any?
  end

  def can_advanced_hunt?
    can_modify_threat_hunts? || can_modify_threat_intel_feeds?
  end

  def can_modify_threat_hunts?
    incident_responder? && billing_account&.plan&.threat_hunting
  end

  def can_modify_threat_intel_feeds?
    incident_responder? && billing_account&.plan&.threat_intel_feeds
  end

  def view_threat_hunts?
    incident_responder?
  end

  def view_devices?
    incident_responder?
  end

  def can_manage_apps?
    editor?
  end

  def can_modify_settings_admin_configs?
    omnipotent?
  end

  def can_modify_agent_release_group?
    omnipotent?
  end

  def defender_enabled_in_tree?
    defender_app && app_enabled_in_tree?(defender_app) && incident_responder?
  end

  def defender_enabled?
    defender_app && app_enabled?(defender_app)
  end

  def defender_action?
    incident_responder?
  end

  def office365_apps_enabled_in_tree?
    any_office365_apps_enabled_in_tree? && incident_responder?
  end

  def triage?
    incident_responder?
  end

  def view_reports?
    user.admin? || viewer?
  end

  def view_cyber_monitoring_report?
    view_reports? && (Flipper.enabled?("reporting/cyber-monitoring", user) ||
      Flipper.enabled?("reporting/cyber-monitoring", record))
  end

  def view_report_executive_summary?
    view_reports? && (Flipper.enabled?("reporting/executive-summary", user) ||
      Flipper.enabled?("reporting/executive-summary", record))
  end

  def view_groups?
    editor?
  end

  def billing_account
    @billing_account ||= record.billing_account
  end

  def can_rerun_card
    billing?
  end

  def create_customers?
    false
  end

  def enable_customer_notifications?
    editor? && record.provider?
  end

  def edit_notifications?
    editor?
  end

  def can_modify_plan?
    billing? && can_modify_own_plan? && (!billing_account.plan&.hide_billing || can_modify_own_plan?)
  end

  def can_reactivate_plan?
    can_modify_plan? && record.canceled?
  end

  def can_modify_own_plan?
    admin? || user_role&.account&.self_and_all_descendants&.where(id: record.id)&.exists?
  end

  def can_modify_disable_sub_subscriptions?
    omnipotent?
  end

  def manage_incidents?
    incident_responder?
  end

  def manage_whitelists?
    editor?
  end

  def search_customers?
    editor?
  end

  def create_incidents?
    soc_operator? || omnipotent?
  end

  def perform_override_actions?
    soc_operator? || omnipotent?
  end

  def perform_antivirus_actions?
    soc_operator? || omnipotent?
  end

  def create_logic_rules?
    soc_operator? || omnipotent?
  end

  def can_generate_api_keys?
    editor?
  end

  def can_manage_integrations?
    record.provider? && !record.distributor? && billing_account.managed? && editor?
  end

  def can_delete_firewalls?
    omnipotent?
  end

  def can_comment_firewalls_and_devices?
    editor?
  end

  def can_move_info?
    editor?
  end

  def can_extend_trial_for_sub_account?
    # check if user has role distributor_billing for any account
    distributor_billing_roles = UserRole.where(user: user, role: :distributor_billing)
    # use those accounts as the root accounts from which to check
    distributor_billing_accounts = Account.joins(:user_roles)
                                          .merge(distributor_billing_roles)
    # ensure that target account is a descendant of at least one of the distributor_billing_accounts
    distributor_billing_accounts.inject(false) do |user_can_extend_sub_account_trial, account|
      user_can_extend_sub_account_trial || account.all_descendants.where(id: record.id).exists?
    end
  end

  Plan.values_for_on_demand_analysis_types.each do |type|
    define_method "can_on_demand_analyze_#{type}?" do
      return false unless can_on_demand_analyze?
      return false if billing_account.trial_expired?
      return true if billing_account.plan&.trial?
      return false if billing_account.plan.nil?

      billing_account.plan.on_demand_analysis_types?(type)
    end
  end

  Plan.values_for_on_demand_hunt_types.each do |type|
    define_method "can_on_demand_hunt_#{type}?" do
      return false unless can_on_demand_hunt?
      return false if billing_account.trial_expired?
      return true if billing_account.plan&.trial?

      billing_account.plan.on_demand_hunt_types?(type)
    end
  end

  # :nodoc
  class Scope < Scope
    def resolve
      if user.omnipotent? || user.soc_operator?
        scope
      else
        scope.where(
          "path <@ array((?))::ltree[]",
          Account.joins(:users).where(users: { id: user.id }).select(:path)
        )
      end
    end
  end

  private

  def defender_app
    @defender_app ||= App.where(configuration_type: :defender).first
  end

  def any_office365_apps_enabled_in_tree?
    @any_office365_apps_enabled_in_tree ||= Apps::Office365App.all.collect do |app|
      app_enabled_in_tree?(app)
    end.include?(true)
  end

  def app_enabled_in_tree?(app)
    AccountApp.where(
      app: app, account: record.root_and_root_descendants,
      disabled_at: nil
    ).where.not(enabled_at: nil).any?
  end

  def app_enabled?(app)
    AccountApp.where(
      app: app, account: record.self_and_ancestors,
      disabled_at: nil
    ).where.not(enabled_at: nil).any?
  end

  def role_accounts
    case record
    when Provider
      record.self_and_ancestors
    when Customer
      Account.where("path @> ?", record.path)
    else
      raise NotImplementedError, "Unable to resolve #{__method__} for record of class: #{record.class}"
    end
  end
end
