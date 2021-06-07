module Api
  module V1
    module Devices
      module Hunts
        # Device hunt starts
        class StartsController < Api::V1::Devices::DevicesBaseController
          include Pundit

          # Hunt started
          def update
            Rails.cache.write("device_#{device.id}:hunt_#{hunt.id}", DateTime.current)
            Broadcasts::Hunts::Start.new(hunt, device).call

            head :created
          end

          private

          def hunt
            @hunt ||= all_hunts.find(hunt_id)
          end

          def identifiers
            @identifiers ||= params[:hunt_id].split("_")
          end

          def hunt_id
            identifiers[1]
          end

          def revision
            identifiers[2]
          end

          def all_hunts
            @all_hunts ||= Hunt.joins(:group).where(
              groups: { account: @device.customer.self_and_all_ancestors }
            )
          end
        end
      end
    end
  end
end
