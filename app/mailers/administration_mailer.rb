# :nodoc
class AdministrationMailer < ApplicationMailer
  def new_account(account)
    @account = account

    mail to: ENV.fetch("NEW_ACCCOUNT_EMAIL", "sales@console.test"), subject: "New Account Created"
  end
end
