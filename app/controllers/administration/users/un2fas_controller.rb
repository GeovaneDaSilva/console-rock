module Administration
  module Users
    # Unlocks a user
    class Un2fasController < Administration::BaseController
      def update
        authorize current_user, :admin?

        if user.remove_two_factor_authentication!
          flash[:notice] = "2FA setup removed"
        else
          flash[:error] = "Unable to remove 2FA from user"
        end

        redirect_to administration_users_path
      end

      private

      def user
        @user ||= User.find(params[:user_id])
      end
    end
  end
end
