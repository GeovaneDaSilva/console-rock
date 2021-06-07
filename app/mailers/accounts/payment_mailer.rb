module Accounts
  # :nodoc
  class PaymentMailer < ApplicationMailer
    def successful_payment(account, charge)
      return if account.billing_account.plan.hide_billing

      @account = account
      @charge  = charge
      owners = mailing_list(account) || owners(account)

      filename = "#{I18n.t('application.name', default: 'SOC').parameterize}-#{charge.id}.pdf"
      attachments[filename] = InvoiceRenderer.new(@charge).call.read
      mail to: emails_with_names(owners), subject: "Successful charge from #{I18n.t('application.name')}"
    end

    def send_invoice(account, charge)
      return if account.billing_account.plan.hide_billing

      @account = account
      @charge  = charge
      owners = mailing_list(account) || owners(account)

      # filename = "#{I18n.t('application.name', default: 'SOC').parameterize}-#{charge.id}.pdf"
      filename = "rocketcyber-#{charge.id}.pdf"
      attachments[filename] = InvoiceRenderer.new(@charge).call.read
      subject_line = "#{@charge.end_date.strftime('%B')} Invoice for #{I18n.t('application.name')}"
      mail to: emails_with_names(owners), subject: subject_line
    end

    def unable_to_charge(account)
      return if account.billing_account.plan.hide_billing

      @account = account
      owners = mailing_list(account) || owners(account)

      mail to: emails_with_names(owners), subject: "Multiple failed charge attempts"
    end

    private

    def owners(account)
      UserRole.joins(:account)
              .where(account: account.self_and_ancestors, role: :owner)
              .order("accounts.path DESC")
              .includes(:user)
              .collect(&:user)
              .uniq
    end

    def mailing_list(account)
      list = account.emails.split(",").map!(&:strip).reject(&:empty?) unless account.emails.nil?
      list ||= Email.where(account: account.self_and_ancestors, category: :billing).pluck(:emails).flatten
      list.empty? ? nil : list
    end
  end
end
