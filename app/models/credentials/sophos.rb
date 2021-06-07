module Credentials
  # :nodoc
  class Sophos < Credential
    attr_json_accessor :keys, :sophos_client_id, :sophos_client_id_iv,
                       :sophos_client_secret, :sophos_client_secret_iv,
                       :organization_id, :organization_id_iv,
                       :partner_id, :partner_id_iv,
                       :tenants

    has_many :app_results, class_name: "Apps::SophosResult", foreign_key: :credential_id,
      dependent: :destroy, inverse_of: :credential

    encrypt :sophos_client_id, key: Base64.decode64(
      ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
    )

    encrypt :sophos_client_secret, key: Base64.decode64(
      ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
    )

    encrypt :organization_id, key: Base64.decode64(
      ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
    )

    encrypt :partner_id, key: Base64.decode64(
      ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
    )

    def self.app_configuration_type
      :sophos_av
    end
  end
end
