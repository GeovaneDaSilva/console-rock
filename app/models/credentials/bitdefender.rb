module Credentials
  # :nodoc
  class Bitdefender < Credential
    has_many :app_results, class_name: "Apps::BitdefenderResult", foreign_key: :credential_id,
      dependent: :destroy, inverse_of: :credential

    DEFAULT_URL = "https://cloud.gravityzone.bitdefender.com/api".freeze

    def self.app_configuration_type
      :bitdefender
    end
  end
end
