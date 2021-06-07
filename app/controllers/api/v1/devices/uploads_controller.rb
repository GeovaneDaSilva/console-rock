module Api
  module V1
    module Devices
      # Device Uploads
      class UploadsController < Api::V1::Devices::DevicesBaseController
        include Uploadable

        private

        def create_upload!
          @upload = @device.uploads.create(upload_params)
        end

        def find_upload
          @upload ||= @device.uploads.find(params[:id])
        end

        def upload_url
          api_device_upload_url(@device, @upload)
        end

        def filesize
          0..200.megabytes
        end

        def acl
          "private"
        end
      end
    end
  end
end
