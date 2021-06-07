module Api
  module V1
    module Customers
      # Apps controller
      class AppsController < Api::V1::Customers::CustomersBaseController
        before_action :apps

        def index; end

        private

        def apps
          @apps ||= App.includes(:upload, :display_image, :display_image_icon)
                       .all
                       .page(params[:page])
                       .per(50)
        end
      end
    end
  end
end
