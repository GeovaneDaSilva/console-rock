# Given an email address, find the user record or invite the user
# Return the user record
class UserInvitor
  def initialize(email, name, invitor, skip_invitation = false, account = nil)
    @email = email.downcase
    @name = name
    @invitor = invitor
    @skip_invitation = skip_invitation
    @account = account
  end

  def call
    user = User.where(email: @email).first

    if user
      user.tap { InvitationMailer.existing(user, @invitor, @account).deliver_later }
    else
      User.invite!(new_user_attrs, @invitor) do |u|
        u.skip_invitation = @skip_invitation
      end
    end
  end

  private

  def new_user_attrs
    {
      email: @email, name: @name, password: password, password_confirmation: password
    }
  end

  def password
    @password ||= Devise.friendly_token[0, 20]
  end
end
