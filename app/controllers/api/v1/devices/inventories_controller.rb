module Api
  module V1
    module Devices
      # Submit device inventory
      class InventoriesController < Api::V1::Devices::DevicesBaseController
        def create
          if device.update(device_params)
            head :created
          else
            head :bad_request
          end
        end

        private

        def device_params
          { inventory_last_updated_at: DateTime.current, inventory_upload_id: params[:upload_id] }
        end
      end
    end
  end
end
