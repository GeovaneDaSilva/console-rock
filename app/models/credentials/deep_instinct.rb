module Credentials
  # :nodoc
  class DeepInstinct < Credential
    attr_json_accessor :keys, :tenants, :msps

    has_many :app_results, class_name: "Apps::DeepInstinctResult", foreign_key: :credential_id,
      dependent: :destroy, inverse_of: :credential

    def self.app_configuration_type
      :deep_instinct
    end
  end
end
