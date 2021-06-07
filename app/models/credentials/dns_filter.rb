module Credentials
  # :nodoc
  class DnsFilter < Credential
    attr_json_accessor :keys, :dns_filter_username, :dns_filter_password, :dns_filter_password_iv,
                       :dns_filter_user_id, :organizations

    has_many :app_results, class_name: "Apps::DnsFilterResult", foreign_key: :credential_id,
      dependent: :destroy, inverse_of: :credential

    encrypt :dns_filter_password, key: Base64.decode64(
      ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
    )

    def self.app_configuration_type
      :dns_filter
    end
  end
end
