module Integrations
  # :nodoc
  module InitializePsaConfig
    # :nodoc
    class SetupPsaConfig
      attr_accessor :type, :credential, :psa_config

      def initialize(type, credential, psa_config)
        @type = type
        @credential = credential
        @psa_config = psa_config
      end

      def call
        ::Integrations::InitializePsaConfig::PullBoardOptions.new(type, credential, psa_config).call
        ::Integrations::InitializePsaConfig::PullCompanyTypes.new(type, credential, psa_config.reload).call
      end
    end
  end
end
