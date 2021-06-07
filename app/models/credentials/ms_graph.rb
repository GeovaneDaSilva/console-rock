module Credentials
  # :nodoc
  class MsGraph < Credential
    has_many :app_results, class_name: "Apps::Office365Result", foreign_key: :credential_id,
      dependent: :destroy, inverse_of: :credential

    def self.app_configuration_type
      :office365
    end
  end
end
