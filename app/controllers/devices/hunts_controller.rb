module Devices
  # All hunts for a device which have been executed
  class HuntsController < AuthenticatedController
    include Pagy::Backend

    before_action :paginate_hunts, only: [:index]

    def index
      authorize device, :show?
    end

    private

    def device
      @device ||= current_account.all_descendant_devices
                                 .find(params[:device_id].downcase)
    end

    def hunts
      Hunt.joins(:group)
          .where(groups: { id: device.group_ids })
          .order("hunts.continuous DESC, hunts.updated_at DESC")
          .enabled
    end

    def paginate_hunts
      @pagination, @hunts = pagy hunts
    end
  end
end
