module Api
  module V1
    module CloudApps
      # AppResults belonging to customer and specific app
      class ResultsController < Api::V1::BaseController
        before_action :account, :payment_requried?

        def create
          # TODO: -- need to figure out timezone.  account.owners.first.timezone seems like
          # it will take too long
          detection = params.dig(:payload, :date) || params.dig(:timestamp)
          detection ||= params.dig(:payload, :payload, :date) || DateTime.current.iso8601
          result = Apps::CloudResult.new(
            app:            app,
            detection_date: DateTime.parse(detection).in_time_zone(timezone),
            details:        params.dig(:result, :payload).permit!,
            customer_id:    account.id,
            account_path:   account.path,
            verdict:        :suspicious,
            value:          "",
            value_type:     ""
          )

          if result.save
            ServiceRunnerJob.perform_later("Apps::Results::Processor", result)

            head :created
          else
            head :bad_request
          end
        end

        private

        # TODO: -- danger of collisions should be low, but consider
        def account
          @account ||= find_account
        end

        def find_account
          acc = RocketcyberIntegrationMap.find_by(target_id: params[:account_id])&.account
          return acc unless acc.nil? && params[:product].downcase == "ess"

          RocketcyberIntegrationMap.find_by(target_id: "ESS#{params[:account_id]}")&.account
        end

        def payment_requried?
          raise PaymentRequiredError if @account.nil? || @account.billing_account&.actionable_past_due?
        end

        def timezone
          UserRole.where(account: account.self_and_ancestors, role: :owner).take.user.timezone || "UTC"
        end

        def app
          @app ||= App.find_by(configuration_type: params[:product].downcase)
        end
      end
    end
  end
end
