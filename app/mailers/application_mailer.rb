# :nodoc
class ApplicationMailer < ActionMailer::Base
  layout "mailer"
  default from:     "#{I18n.t('application.name', default: 'SOC')} " \
                "<#{ENV.fetch(I18n.t('application.support_email'), 'support@console.com')}>",
          reply_to: ENV.fetch(I18n.t("application.support_email"), "support@console.com")

  private

  def emails_with_names(user_collection)
    return user_collection if user_collection.first.class == String

    user_collection.collect { |user| "#{user.name} <#{user.email}>" }
  end
end
