module Api
  module V1
    module Devices
      # Device hunts
      class HuntsController < Api::V1::Devices::DevicesBaseController
        include Pundit

        before_action :hunts, only: [:index]
        before_action :hunt, only: [:show]

        def index; end

        def show
          respond_to do |format|
            format.json
            format.lua do
              # send_data(lua_script, type: "text/plain", filename: "#{hunt.file_identifier(revision)}.lua")
            end
          end
        end

        private

        def hunt
          @hunt ||= all_hunts.find(hunt_id)
        end

        def identifiers
          @identifiers ||= params[:id].split("_")
        end

        def hunt_id
          identifiers[1]
        end

        def revision
          identifiers[2]
        end

        def all_hunts
          @all_hunts ||= Hunt.includes(:group).where(
            groups: { account: @device.customer.self_and_all_ancestors }
          )
        end

        def hunts
          @hunts = Hunt.enabled
                       .includes(:group)
                       .where(id: @device.queued_hunts.pluck(:hunt_id))
                       .order("hunts.feed_result_id DESC, hunts.updated_at ASC")

          @hunts = @hunts.page(params[:page]).per(50)
        end

        def groups
          @groups ||= Group.where(account: root_and_all_descendants)
        end

        def lua_script
          ApplicationController.renderer.render(
            "api/v1/devices/hunts/show.lua", locals: { hunt: hunt, revision: revision }, format: :lua
          )
        end
      end
    end
  end
end
