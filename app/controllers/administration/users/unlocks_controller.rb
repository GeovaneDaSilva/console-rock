module Administration
  module Users
    # Unlocks a user
    class UnlocksController < Administration::BaseController
      def update
        authorize current_user, :admin?

        if user.update(second_factor_attempts_count: 0)
          flash[:notice] = "Unlocked user"
        else
          flash[:error] = "Unable to unlock user"
        end

        redirect_to(request.referer || administration_users_path)
      end

      private

      def user
        @user ||= User.find(params[:user_id])
      end
    end
  end
end
