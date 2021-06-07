module Credentials
  # :nodoc
  class Webroot < Credential
    has_many :app_results, class_name: "Apps::WebrootResult", foreign_key: :credential_id,
      dependent: :destroy, inverse_of: :credential

    def self.app_configuration_type
      :webroot
    end
  end
end
