# :nodoc
module Incidents
  # :nodoc
  class Integrations
    def self.create_psa_config(credential)
      ServiceRunnerJob.perform_later("Integrations::#{credential.type}::CreatePsaConfig", credential.id)
    end

    def self.create_ticket(incident)
      psa_config = incident.account.psa_config

      if !psa_config.nil?
        credentials = Credential.where(account: incident.account.self_and_all_ancestors, type: "Credentials::#{psa_config.psa_type}")
        # Rails.logger.info("Incidents::Integrations.create_ticket - credentials count: #{credentials.size}, incident: #{incident.id}")
        return unless credentials.size == 1

        ServiceRunnerJob.perform_later(
          "Integrations::#{psa_config.psa_type}::TicketActions", "create_ticket", credentials.first, incident, psa_config
        )
        # return if Email.where(account_id: incident.account.self_and_all_ancestors, category: :security).empty?
      end

      incident.account.self_and_all_ancestors.each do |account|
        Accounts::Apps::IncidentsMailer.notify(account, incident).deliver_later
      end
    end

    def self.update_ticket(incident, incident_params, _account)
      # prior to the addition of PsaConfig, we did not have any ability to close tickets
      psa_config = incident.account.psa_config
      return if psa_config.nil?

      credentials = Credential.where(account: incident.account.self_and_all_ancestors, type: "Credentials::#{psa_config.psa_type}")

      ServiceRunnerJob.perform_later(
        "Integrations::#{psa_config.psa_type}::TicketActions", "update_ticket", credentials.first, incident, psa_config, nil, incident_params
      )
    end

    def self.close_ticket(incident, _account)
      # prior to the addition of PsaConfig, we did not have any ability to close tickets
      psa_config = incident.account.psa_config
      return if psa_config.nil?

      credentials = Credential.where(account: incident.account.self_and_all_ancestors, type: "Credentials::#{psa_config.psa_type}")
      # return unless credentials.size == 1

      ServiceRunnerJob.perform_later(
        "Integrations::#{psa_config.psa_type}::TicketActions", "close_ticket", credentials.first, incident, psa_config
      )
    end

    # def self.destroy_ticket(incident)
    #   # prior to the addition of PsaConfig, we did not have any ability to close tickets
    #   psa_config = incident.account.psa_config
    #   return if psa_config.nil?
    #
    #   ServiceRunnerJob.perform_later(
    #     "Integrations::#{psa_config.psa_type}", "destroy_ticket", incident
    #   )
    # end
  end
end
