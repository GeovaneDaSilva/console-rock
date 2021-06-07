module Api
  module V1
    module Devices
      # Device's agent logs
      class AgentLogsController < Api::V1::Devices::DevicesBaseController
        def create
          agent_log = @device.agent_logs.new(upload: upload)

          if agent_log.save
            head :created
          else
            head :bad_request
          end
        end

        private

        def upload
          # TODO: Swap for a Pundit policy if/when it makes sense
          @upload ||= @device.uploads.find(params[:upload_id])
        end
      end
    end
  end
end
