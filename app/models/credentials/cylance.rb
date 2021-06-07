module Credentials
  # :nodoc
  class Cylance < Credential
    has_many :app_results, class_name: "Apps::CylanceResult", foreign_key: :credential_id,
      dependent: :destroy, inverse_of: :credential

    def self.app_configuration_type
      :cylance
    end
  end
end
