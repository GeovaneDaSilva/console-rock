module Integrations
  # :nodoc
  module InitializePsaConfig
    # :nodoc
    class PullBoardStatuses
      attr_accessor :type, :credential, :psa_config

      def initialize(type, credential, psa_config)
        @type = type
        @credential = credential
        @psa_config = psa_config
      end

      def call
        return if credential.nil? || !credential.is_a?(Credential)

        if type == "Connectwise"
          options = Integrations::Connectwise::SetupActions.get_board_statuses(credential, psa_config)
          psa_config.update(status_codes: options)
        elsif type == "Datto"
          true
        elsif type == "Syncro"
          true
        end
      end
    end
  end
end
