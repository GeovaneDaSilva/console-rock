module Accounts
  module Users
    # Resend an invitation email
    class InvitationsController < AuthenticatedController
      def create
        authorize user_role, :resend_invitation?

        InvitationMailer.existing(user, user.invited_by || current_user, user_role.account).deliver_later
        flash.now[:notice] = "Resent invitation email"
      end

      private

      def user
        user_role.user
      end

      def user_role
        @user_role ||= UserRole.find(params[:user_id])
      end
    end
  end
end
