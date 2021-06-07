# Notification Emails
class NotificationMailer < ApplicationMailer
  # layout "notification_mailer"
  default from: "#{I18n.t('application.name', default: '')} Breach Notifications " \
                "<#{ENV.fetch(I18n.t('application.notification_email'), 'support@console.test')}>"

  def malicious_indicator(email, account, body)
    @body    = body
    @account = account

    return if @account.billing_account&.managed?

    set_locale

    mail to: email.split(","), subject: "Malicious activity detected"
  end

  def suspicious_indicator(email, account, body)
    @body    = body
    @account = account

    return if @account.billing_account&.managed?

    set_locale

    mail to: email.split(","), subject: "Suspicious activity detected"
  end

  def device_inactivity(email, account, body)
    @body    = body
    @account = account
    set_locale

    return if email.blank?

    mail to: email.split(","), subject: "Inactive devices"
  end

  def syslog_server_offline(email, account, body)
    @body    = body
    @account = account

    return if email.blank?

    set_locale

    mail to: email.split(","), subject: "Syslog server offline"
  end

  def soc_rule(account, app_result, rule)
    @app_result = app_result
    @account = account
    @rule = rule
    set_locale

    return unless @account.billing_account&.managed?

    mail to: ENV.fetch("SOC_EMAIL", "socops2@console.test"), subject: "Automated Alert"
  end

  def set_locale
    I18n.locale ||= extract_locale || I18n.default_locale
  end

  def extract_locale
    return unless @account

    locale = @account.billing_account&.plan&.plan_type
    I18n.available_locales.map(&:to_s).include?(locale) ? locale : nil
  end
end
