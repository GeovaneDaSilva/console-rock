# Policy for controlling administration access
class AdministrationPolicy < Struct.new(:user, :administration)
  delegate :admin?, :omnipotent?, :soc_operator?, to: :user

  def provision_providers?
    omnipotent?
  end

  def modify_support_files?
    omnipotent?
  end

  def manage_plans?
    omnipotent?
  end

  def manage_system_hunts?
    soc_operator? || omnipotent?
  end

  def manage_apps?
    omnipotent?
  end

  def manage_agent_releases?
    omnipotent?
  end

  def manage_flipper?
    omnipotent?
  end

  def manage_incidents?
    soc_operator? || omnipotent?
  end

  def manage_crash_reports?
    omnipotent?
  end

  def managed_triage?
    soc_operator? || omnipotent?
  end

  def notify_devices_of_app_update?
    omnipotent? && Rails.cache.read("app-update-notification").nil?
  end

  def method_missing(method, *_args, &_blk)
    return admin? if method =~ /\?$/

    super
  end

  def respond_to_missing?(method, *)
    method =~ /\?$/
  end
end
