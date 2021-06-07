module Integrations
  # :nodoc
  module InitializePsaConfig
    # :nodoc
    class PullBoardOptions
      attr_accessor :type, :credential, :psa_config

      def initialize(type, credential, psa_config = nil)
        @type = type
        @credential = credential
        @psa_config = psa_config
      end

      # rubocop:disable Metrics/MethodLength
      def call
        return if credential.nil? || !credential.is_a?(Credential)

        psa_config ||= PsaConfig.where(
          account_id:    credential.account_id,
          credential_id: credential.id
        ).first_or_initialize
        psa_config.psa_type = type
        if type == "Connectwise"
          options = Integrations::Connectwise::SetupActions.get_boards(credential)
          psa_config.board_options = options
        elsif type == "Datto"
          update_hash = Integrations::Datto::SetupActions.get_boards(credential)
          update_hash.each { |k, v| psa_config.send("#{k}=", v) }
        elsif type == "Syncro"
          update_hash = Integrations::Syncro::SetupActions.pull_setup_data(credential)
          update_hash.each { |k, v| psa_config.send("#{k}=", v) }
        elsif type == "Kaseya"
          update_hash = Integrations::Kaseya::SetupActions.pull_setup_data(credential)
          update_hash.each { |k, v| psa_config.send("#{k}=", v) }
        end
        psa_config.save!
        psa_config
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
