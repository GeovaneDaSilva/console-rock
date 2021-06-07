# Email to send info about TTP's
class TTPMailer < ApplicationMailer
  def new_ttps(ttps)
    ttps = ttps.reject(&:blank?) if ttps.is_a? Array
    @ttps = TTP.find(ttps)
    return if @ttps.blank?

    mail to: ENV.fetch("NEW_TTP_EMAIL", "support@console.test"), subject: "New TTP(s) Found"
  end
end
