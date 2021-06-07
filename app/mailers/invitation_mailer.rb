# :nodoc
class InvitationMailer < ApplicationMailer
  def existing(user, invited_by = nil, account = nil)
    @user = user
    @invited_by = invited_by
    @account = account

    mail to:      emails_with_names([@user]),
         from:    "<#{ENV.fetch(I18n.t('application.notification_email'), 'support@console.test')}>",
         subject: "Invitation to Collaborate on #{I18n.t('application.name')} Managed SOC"
  end
end
