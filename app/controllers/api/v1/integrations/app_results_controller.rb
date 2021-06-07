module Api
  module V1
    module Integrations
      # API endpoint to GET (list or get one) RocketCyber app results
      class AppResultsController < Api::V1::Integrations::Pax8BaseController
        # by extending Pax8BaseController, these all have "authenticate" as a before_action

        def index
          # offset = (params[:page] || 0) * 100
          # limit = 100
          # # TODO: make pagination for more than X results
          # results = if date_params.nil?
          #             account.all_descendant_app_results.where(filter_params).offset(offset).limit(limit)
          #           else
          #             account.all_descendant_app_results.where(filter_params).where(date_params)
          #                    .offset(offset).limit(limit)
          #           end
          ids = params[:ids].split(",").map(&:to_i)
          results = account.all_descendant_app_results.where(id: ids)

          render json: (results || []).to_json
        end

        def show
          result = account.all_descendant_app_results.find_by(id: params[:id])
          # TODO: would be faster to do a straight DB lookup by ID, but how to verify in the
          # credential's scope?

          { json: result.to_json }
        end

        # private

        # def filter_params
        #   filters = {}
        #   filters[id: params[:ids]] if params[:ids]
        #   filters[archive_status: params[:status]] if params[:status]
        #   filters
        # end
        #
        # def date_params
        #   start_date = nil
        #   end_date = nil
        #   start_date = "created_at > #{params[:start_date]}" if params[:start_date]
        #   end_date = "created_at < #{params[:end_date]}" if params[:end_date]
        #
        #   if start_date && end_date
        #     start_date + " AND " + end_date
        #   else
        #     start_date || end_date
        #   end
        # end
      end
    end
  end
end
