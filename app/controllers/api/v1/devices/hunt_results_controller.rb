module Api
  module V1
    module Devices
      # Device's hunt results
      class HuntResultsController < Api::V1::Devices::DevicesBaseController
        def create
          hunt_result = device.hunt_results.new(hunt: hunt, account_path: customer.path)
          hunt_result.assign_attributes(hunt_result_params)

          if hunt_result.save
            ServiceRunnerJob.set(wait: rand(2..2000).seconds)
                            .perform_later("HuntResults::Processor", hunt_result)
            head :created
          else
            head :bad_request
          end
        end

        private

        def hunt
          # TODO: Swap for a Pundit policy if/when it makes sense
          @hunt ||= Hunt.where(group_id: device.group_ids)
                        .find(params[:hunt_id])
        end

        def hunt_result_params
          params.permit(:revision, :upload_id, :status, tags: [])
        end
      end
    end
  end
end
