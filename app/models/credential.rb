# :nodoc
class Credential < ApplicationRecord
  include AttrJsonable
  include Encryptable

  audited

  before_create :enable_app

  attr_json_accessor :keys, :refresh_token, :access_token, :expires_at, :refresh_token_iv, :access_token_iv,
                     :cylance_app_id, :cylance_app_secret, :cylance_app_id_iv, :cylance_app_secret_iv,
                     :webroot_basic_auth_string, :webroot_basic_auth_string_iv, :webroot_gsm_key,
                     :webroot_gsm_key_iv, :webroot_username, :webroot_username_iv, :webroot_password,
                     :webroot_password_iv, :sites, :sentinelone_url, :bitdefender_url, :ms_base_domains,
                     :base_url, :datto_psa_secret, :datto_psa_username, :datto_psa_secret_iv,
                     :datto_psa_username_iv, :connectwise_psa_public_api_key,
                     :connectwise_psa_private_api_key, :connectwise_psa_public_api_key_iv,
                     :connectwise_psa_private_api_key_iv, :connectwise_company_id, :connectwise_host,
                     :syncro_api_key, :syncro_api_key_iv, :hibp_api_key, :hibp_api_key_iv,
                     :kaseya_username, :kaseya_password, :kaseya_tenant, :kaseya_password_iv, :token_type,
                     :duo_integration_key, :duo_integration_key_iv, :duo_secret, :duo_secret_iv,
                     :duo_host, :duo_host_iv, :is_working,
                     :app_key, :app_secret, :app_key_iv, :app_secret_iv

  belongs_to :customer
  belongs_to :account

  validates :account_id, numericality: { greater_than: 0 }
  # validates :sentinelone_url, format: { with:    /\Ahttps:\/\/\S+\.net\z/,
  #                                       message:
  # rubocop:disable Layout/LineLength
  #                                                "Error: Please enter https://url of your login screen without \"/login\" or \"/dashboard\" and no trailing /" }
  # rubocop:enable Layout/LineLength
  #
  has_one :psa_config, dependent: :destroy

  encrypt :app_key, key: Base64.decode64(
    ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
  )

  encrypt :app_secret, key: Base64.decode64(
    ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
  )

  encrypt :refresh_token, key: Base64.decode64(
    ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
  )

  encrypt :access_token, key: Base64.decode64(
    ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
  )

  encrypt :webroot_basic_auth_string, key: Base64.decode64(
    ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
  )

  encrypt :webroot_gsm_key, key: Base64.decode64(
    ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
  )

  encrypt :webroot_password, key: Base64.decode64(
    ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
  )

  encrypt :webroot_username, key: Base64.decode64(
    ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
  )

  encrypt :cylance_app_id, key: Base64.decode64(
    ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
  )

  encrypt :cylance_app_secret, key: Base64.decode64(
    ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
  )

  encrypt :hibp_api_key, key: Base64.decode64(
    ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
  )

  encrypt :datto_psa_username, key: Base64.decode64(
    ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
  )

  encrypt :datto_psa_secret, key: Base64.decode64(
    ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
  )

  encrypt :connectwise_psa_public_api_key, key: Base64.decode64(
    ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
  )

  encrypt :connectwise_psa_private_api_key, key: Base64.decode64(
    ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
  )

  encrypt :syncro_api_key, key: Base64.decode64(
    ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
  )

  encrypt :kaseya_password, key: Base64.decode64(
    ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
  )

  encrypt :duo_integration, key: Base64.decode64(
    ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
  )

  encrypt :duo_secret, key: Base64.decode64(
    ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
  )

  encrypt :duo_host, key: Base64.decode64(
    ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
  )

  def self.app_configuration_type
    raise NotImplementedError
  end

  def enable_app
    account&.account_apps
      &.joins("JOIN apps ON apps.id=account_apps.app_id")
      &.where("apps.configuration_type = ?",
              App.configuration_types[self.class.app_configuration_type])
      &.update_all(disabled_at: nil, enabled_at: Time.current)
  rescue NotImplementedError
    Rails.logger.error("enable_app not implemented for #{self.class}")
    nil
  end

  def psa_type
    type.split("::")[1]
  end
end
