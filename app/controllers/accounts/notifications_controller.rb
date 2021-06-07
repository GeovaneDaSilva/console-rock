module Accounts
  # CRUD operations on account notifications
  # Will eventually replace subscriptions
  class NotificationsController < AuthenticatedController
    def create
      authorize account, :edit_notifications?

      unless save_emails
        flash[:error] = "Failed to save an email: invalid format"
        redirect_back fallback_location: root_url
        return
      end

      unless save_phone_numbers
        flash[:error] = "Failed to save phone: invalid format"
        redirect_back fallback_location: root_url
        return
      end

      flash[:notice] = "Success"
      redirect_back fallback_location: root_url
    end

    private

    def account
      @account ||= Account.find(params[:account_id])
    end

    def save_emails
      email_notification_types.each do |type|
        data = send("#{type}_email")
        next if data.nil?

        email = Email.where(account: account, category: type).first_or_create
        next if email.update(emails: data)

        return false
      end
      true
    end

    def save_phone_numbers
      phone_notification_types.each do |type|
        data = send("#{type}_phone")
        next if data.nil?

        email = Phone.where(account: account, category: type).first_or_create
        next if email.update(numbers: data)

        return false
      end
      true
    end

    def email_notification_types
      %i[billing business security]
    end

    def phone_notification_types
      %i[security]
    end

    def billing_email
      params[:billing_email]&.split(",")&.map(&:strip)
    end

    def business_email
      params[:business_email]&.split(",")&.map(&:strip)
    end

    def security_email
      params[:security_email]&.split(",")&.map(&:strip)
    end

    def security_phone
      params[:security_phone]&.split(",")&.map(&:strip)
    end
  end
end
