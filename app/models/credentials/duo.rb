module Credentials
  # :nodoc
  class Duo < Credential
    has_many :app_results, class_name: "Apps::DuoResult", foreign_key: :credential_id,
      dependent: :destroy, inverse_of: :credential

    def self.app_configuration_type
      :duo
    end
  end
end
