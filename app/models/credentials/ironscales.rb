module Credentials
  # :nodoc
  class Ironscales < Credential
    attr_json_accessor :keys, :company_id, :company_name, :company_domain, :companies

    has_many :app_results, class_name: "Apps::IronscalesResult", foreign_key: :credential_id,
      dependent: :destroy, inverse_of: :credential

    validates :refresh_token, presence: true

    def self.app_configuration_type
      :ironscales
    end
  end
end
