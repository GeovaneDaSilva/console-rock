# :nodoc
module Ironscales
  # :nodoc
  module Services
    # Runs each thing that needs to be run for Ironscales.
    # Meant to be used either to start (initiates first pull) or to restart (to recover from major outage)
    class Runner
      include ErrorHelper

      def initialize(cred)
        @cred = cred.is_a?(Integer) ? Credentials::Ironscales.find(cred) : cred
      rescue ActiveRecord::RecordNotFound, NoMethodError
        @cred = nil
      end

      def call
        return if @cred.nil? || !@cred.instance_of?(Credentials::Ironscales)

        (@cred.companies || []).each do |company|
          # incidents
          ServiceRunnerJob.set(queue: :utility).perform_later(
            "Ironscales::Services::Pull", @cred.id, params(company, "incidents")
          )
          # impersonations
          ServiceRunnerJob.set(queue: :utility).perform_later(
            "Ironscales::Services::Pull", @cred.id, params(company, "impersonation")
          )
        end
      end

      private

      def params(company, type)
        base_params = {
          company_id: company["id"],
          url:        "https://members.ironscales.com:443/appapi/" \
            "mitigation/#{company['id']}/#{type}/details/",
          period:     1
        }
        if type == "impersonation"
          base_params[:save_template] = "Ironscales::SaveTemplates::Impersonations"
        else
          base_params[:call_details] = true
        end

        base_params
      end
    end
  end
end
