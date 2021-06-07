# :nodoc
class AccountsController < AuthenticatedController
  helper_method :apps, :discreet_apps
  include ProviderHelper

  def index
    if current_account
      authorize(current_account, :show?)
    elsif current_user.admin_role
      skip_authorization

      redirect_to administration_providers_path
    else
      skip_authorization

      redirect_to new_provider_path
    end
  end

  def sales
    if current_account
      authorize(current_account, :can_modify_settings_admin_configs?)
    elsif current_user.admin_role
      skip_authorization

      redirect_to administration_providers_path
    else
      skip_authorization

      redirect_to new_provider_path
    end
  end

  private

  def apps
    @apps ||= filter_managed_apps.enabled.ga.order("title ASC").includes(:display_image_icon).load
  end

  def discreet_apps
    filter_managed_apps.discreet
  end

  def filter_managed_apps
    current_account&.managed? ? App.all : App.unmanaged_only
  rescue NoMethodError
    App.all
  end
end
