module Accounts
  # manage users for an account
  class UsersController < AuthenticatedController
    before_action :account
    before_action :user_role, only: %i[edit update destroy]

    def new
      # TODO: changing .keys.last to [:viewer]
      # This is not a good long-term change, but it is not clear what we want to do with the "report viewer"
      # role (which is .last).  At present, it has so few permissions
      # you cause an error just trying to view the site.
      @user_role = account.user_roles.new(
        role: UserRole.roles[:viewer]
      )
      @user = User.new

      authorize @user_role
    end

    def create
      @user_role = account.user_roles.new(user_role_attributes)

      authorize @user_role

      @user_role.user = invite_user

      if @user_role.valid? && @user_role.user.valid?
        flash[:notice] = "Successfully added #{@user.name}"
        @user_role.save
        @user.update(session_timeout: user_attributes[:session_timeout])

        redirect_to users_path
      else
        flash.now[:error] = "Unable to add user"

        render "new"
      end
    end

    def edit
      authorize(@user_role)
      @user = @user_role.user
    end

    def update
      @user_role.assign_attributes(user_role_attributes)
      authorize(@user_role)

      if @user_role.save
        flash[:notice] = "Successfully updated #{@user_role.user.name}'s permissions"

        redirect_to users_path
      else
        flash.now[:error] = "Unable to update #{@user_role.user.name}'s permissions"
        render "edit"
      end
    end

    def destroy
      authorize(@user_role)
      user = @user_role.user

      if @user_role.destroy
        flash[:notice] = "Successfully removed #{user.name}'s access"
        return redirect_to root_path if user == current_user
      else
        flash[:error] = "Unable to remove #{user.name}'s access"
      end

      redirect_to users_path
    end

    private

    def account
      @account ||= Account.find(params[:account_id])
    end

    def users_path
      if account.provider?
        provider_path(account, anchor: "permissions")
      elsif account.customer?
        customer_path(account, anchor: "permissions")
      end
    end

    def invite_user
      full_name = [user_attributes[:first_name], user_attributes[:last_name]].join(" ")
      @user = UserInvitor.new(user_attributes[:email], full_name, current_user, false, account).call
    end

    def user_role
      @user_role ||= account.user_roles.includes(:user).find(params[:id])
    end

    def user_attributes
      params.require(:user_role).require(:user).permit(:first_name, :last_name, :email, :session_timeout)
    end

    def user_role_attributes
      params.require(:user_role).permit(:role)
    end
  end
end
