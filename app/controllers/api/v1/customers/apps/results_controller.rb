module Api
  module V1
    module Customers
      module Apps
        # AppResults belonging to customer and specific app
        class ResultsController < Api::V1::Customers::CustomersBaseController
          before_action :find_app
          before_action :app_results

          def index; end

          private

          def find_app
            @app = App.find(params[:app_id])
          end

          def app_results
            @app_results ||= @customer.all_descendant_app_results
                                      .where(app: @app)
                                      .order(detection_date: :desc)
                                      .page(params[:page])
                                      .per(10)
          end
        end
      end
    end
  end
end
