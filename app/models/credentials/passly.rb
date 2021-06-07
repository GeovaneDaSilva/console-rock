module Credentials
  # :nodoc
  class Passly < Credential
    has_many :app_results, class_name: "Apps::PasslyResult", foreign_key: :credential_id,
      dependent: :destroy, inverse_of: :credential

    attr_json_accessor :keys, :app_id, :app_id_iv, :app_secret, :app_secret_iv, :organizations

    encrypt :app_id, key: Base64.decode64(
      ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
    )

    encrypt :app_secret, key: Base64.decode64(
      ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
    )

    def self.app_configuration_type
      :passly
    end
  end
end
