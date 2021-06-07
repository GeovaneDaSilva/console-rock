module Administration
  # Admin views for users
  class UsersController < Administration::BaseController
    include Pagy::Backend

    before_action :user, only: %i[edit update]

    def index
      authorize(:administration, :view_users?)
      filter = ::Filters::Administration::UserFilter.new(filter_params)

      @pagination, @users = pagy filter.filter, items: 10
    end

    def edit
      authorize(:administration, :edit_users?)
    end

    def update
      authorize(:administration, :edit_users?)

      if user.update(user_params)
        flash[:notice] = "Updated user"
        redirect_to administration_users_path
      else
        flash.now[:error] = "Unable to update user"
        render :edit
      end
    end

    private

    def user
      @user ||= User.find(params[:id])
    end

    def filter_params
      params.permit(:search, :page)
    end

    def user_params
      params.require(:user).permit(
        :first_name, :last_name, :email, :timezone, :password, :password_confirmation
      ).reject { |_, v| v.blank? }
    end
  end
end
