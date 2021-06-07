module Accounts
  # Set a payment's credit card
  class CreditCardsController < AuthenticatedController
    helper_method :account
    def new
      authorize account, :can_modify_plan?
    end

    def create
      authorize account, :can_modify_plan?

      return charge_card(true) if params[:charge_card]

      Braintree::CustomerBuilder.new(account).call if account.braintree_customer_id.blank?

      if payment_method_token.success?
        update_account!
        flash[:notice] = "Credit card added as your payment method"
        redirect_to account_path(account, anchor: "billing")
      else
        Rails.logger.tagged("PaymentError") do
          Rails.logger.fatal(
            "Unable to add payment method for Account #{account.name}:#{account.id} \
            #{payment_method_token.errors.inspect} \n\r #{payment_method_token.verification.inspect}"
          )
        end
        flash.now[:error] = "Unable to add credit card as your payment method"
        render "new"
      end
    end

    private

    def account
      @account ||= Account.find(params[:account_id])
    end

    def skip_credit_card_required?
      true
    end

    def charge_card(force_charge_now)
      ServiceRunnerJob.perform_later("Charges::Charger", account, account.plan, force_charge_now)
    end

    def update_account!
      account.update(
        card_type:                 payment_method_token.payment_method.card_type,
        card_masked_number:        payment_method_token.payment_method.masked_number,
        card_payment_method_token: payment_method_token.payment_method.token,
        status:                    :active
      )

      charge_card(false) if account.past_due?
    end

    def payment_method_token
      @payment_method_token ||= Braintree::PaymentMethod.create(
        customer_id:          account.id,
        payment_method_nonce: params[:credit_card_nonce],
        options:              {
          verify_card:  true,
          make_default: true
        }
      )
    end
  end
end
