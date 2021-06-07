module Integrations
  # :nodoc
  module InitializePsaConfig
    # :nodoc
    class PullCompanies
      attr_accessor :type, :credential, :psa_config

      def initialize(type, credential, psa_config)
        @type = type
        @credential = credential
        @psa_config = psa_config

        @errors = {}
      end

      attr_reader :errors

      def call
        return if credential.nil? || !credential.is_a?(Credential)

        existing = psa_config.companies || []
        options = []

        if type == "Connectwise"
          options = Integrations::Connectwise::SetupActions.get_companies(credential, psa_config) || []
        elsif type == "Datto"
          options = Integrations::Datto::SetupActions.get_companies(credential, psa_config)
        elsif type == "Syncro"
          options = Integrations::Syncro::SetupActions.pull_companies(credential)
        elsif type == "Kaseya"
          options, location_map = Integrations::Kaseya::SetupActions.pull_companies(credential, psa_config)
          psa_config.kaseya_location_map = location_map
        end

        options = (options + existing)&.uniq&.sort_by { |name, _id| name.downcase }
        psa_config.companies = options
        psa_config.save

        psa_config
      end

      def errors?
        errors.present?
      end

      private

      def capture_errors(key, result)
        errors[key.to_sym] = result.errors if result.errors?
      end
    end
  end
end
