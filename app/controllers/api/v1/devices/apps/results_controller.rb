module Api
  module V1
    module Devices
      module Apps
        # Device App Results
        class ResultsController < Api::V1::Devices::DevicesBaseController
          def create
            return if params[:verdict] == "benign"

            # Rails.logger.debug("App Result Params: #{params.inspect}")

            result = device.app_results.new(
              result_params.merge(
                app:            app,
                detection_date: detection_date.in_time_zone(device.timezone),
                details:        params[:details].permit!,
                customer_id:    device.customer_id,
                account_path:   customer.path
              )
            )

            if result.save
              ServiceRunnerJob.perform_later("Apps::Results::Processor", result)

              head :created
            else
              head :bad_request
            end
          end

          private

          def result_params
            params.permit(:verdict, :value, :value_type)
          end

          def app
            App.find(params[:app_id])
          end

          def account_app
            @account_app ||= all_account_apps.find(params[:app_id])
          end

          def all_account_apps
            @all_account_apps ||= AccountApp.where(
              account:     device.customer.self_and_all_ancestors,
              disabled_at: nil
            )
          end

          def detection_date
            Time.parse(params[:detection_date] + "-00:00").utc
          rescue ArgumentError, TypeError
            Time.at(params[:detection_date].to_f).utc
          end
        end
      end
    end
  end
end
