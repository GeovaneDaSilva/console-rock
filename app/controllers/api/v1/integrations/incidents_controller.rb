module Api
  module V1
    module Integrations
      # API endpoint which allows GET (list all and pick one) operations on RocketCyber incidents
      class IncidentsController < Api::V1::Integrations::Pax8BaseController
        # by extending Pax8BaseController, these all have "authenticate" as a before_action

        def index
          incidents = account.all_descendant_incidents
          incidents = filter(incidents)

          render json: build_response(incidents)
        end

        def show
          incident = account.all_descendant_incidents.find_by(id: params[:id])

          { json: build_response(incident) }
        end

        private

        def filter(incident_list)
          incident_list = incident_list.where(id: params[:ids]) if params[:ids]

          # date in ISO 8601
          incident_list = incident_list.where("created_at > ?", params[:start_date]) if params[:start_date]
          incident_list = incident_list.where("created_at < ?", params[:end_date]) if params[:end_date]
          incident_list = incident_list.where(state: params[:status]) if params[:status]
          incident_list
        end

        def build_response(incident_list)
          {
            incidents: incident_list.as_json(
              only:    %i[id title description remediation state resolved_at published_at created_at],
              include: {
                creator:  { only: [:email] },
                resolver: { only: [:email] },
                account:  { only: %i[id name] },
                results:  { only: [:id] }
              }
            )
          }.to_json
        end
      end
    end
  end
end
