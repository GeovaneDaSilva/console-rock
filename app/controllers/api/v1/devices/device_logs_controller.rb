module Api
  module V1
    module Devices
      # Device logs (either firewall logs or device logs)
      class DeviceLogsController < Api::V1::Devices::DevicesBaseController
        def create
          device_log = @device.device_logs.new(upload: upload, customer: @device.customer)

          if device_log.save
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
