module Integrations
  # :nodoc
  module InitializePsaConfig
    # :nodoc
    class PullCompanyTypes
      attr_accessor :type, :credential, :psa_config

      def initialize(type, credential, psa_config)
        @type = type
        @credential = credential
        @psa_config = psa_config
      end

      def call
        return if credential.nil? || !credential.is_a?(Credential)

        if type == "Connectwise"
          options = Integrations::Connectwise::SetupActions.get_company_types(credential)
          psa_config.update(company_types: options)
        elsif type == "Datto"
          true
        elsif type == "Syncro"
          true
        elsif type == "Kaseya"
          true
        end
      end
    end
  end
end
