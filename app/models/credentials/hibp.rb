module Credentials
  # :nodoc
  class Hibp < Credential
    attr_json_accessor :keys, :emails, :domains

    has_many :app_results, class_name: "Apps::HibpResult", foreign_key: :credential_id,
      dependent: :destroy, inverse_of: :credential

    def self.app_configuration_type
      :hibp
    end
  end
end
