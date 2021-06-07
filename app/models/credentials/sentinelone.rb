module Credentials
  # :nodoc
  class Sentinelone < Credential
    has_many :app_results, class_name: "Apps::SentineloneResult", foreign_key: :credential_id,
      dependent: :destroy, inverse_of: :credential

    def self.app_configuration_type
      :sentinelone
    end
  end
end
