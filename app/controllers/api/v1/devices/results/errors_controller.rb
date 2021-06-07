module Api
  module V1
    module Devices
      module Results
        # :nodoc
        class ErrorsController < Api::V1::Devices::DevicesBaseController
          def update
            app_result.update(
              action_state:  :errored,
              action_result: result_details
            )

            head :accepted
          rescue ActiveRecord::RecordNotFound
            head :accepted
          end

          private

          def app_result
            @app_result ||= device.app_results.find(params[:result_id])
          end

          def result_details
            app_result.action_result.merge(
              errored: params[:details].permit!.merge(date: DateTime.current)
            )
          end
        end
      end
    end
  end
end
