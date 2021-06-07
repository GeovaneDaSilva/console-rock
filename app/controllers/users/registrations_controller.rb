module Users
  # Override some registration logic
  class RegistrationsController < Devise::RegistrationsController
    before_action :confirm_two_factor_authenticated, except: %i[new create cancel]

    private

    def sign_up_params
      super.update from_sign_up: true
    end

    def update_resource(resource, params)
      if session[:oauth_user] ||
         params[:password].blank? &&
         params[:email] == resource.email
        no_password_params = params.reject { |k| k == "current_password" }
        resource.update_without_password(no_password_params)
      else
        resource.update_with_password(params)
      end
    end

    def confirm_two_factor_authenticated
      return if is_fully_authenticated?

      flash[:error] = "Not authenticated"
      redirect_to user_two_factor_authentication_url
    end
  end
end
