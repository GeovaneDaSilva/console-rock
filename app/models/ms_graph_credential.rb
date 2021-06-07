# :nodoc
class MsGraphCredential < ApplicationRecord
  include AttrJsonable
  include Encryptable

  attr_json_accessor :keys, :refresh_token, :access_token, :expires_at, :refresh_token_iv, :access_token_iv

  belongs_to :customer

  encrypt :refresh_token, key: Base64.decode64(
    ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
  )

  encrypt :access_token, key: Base64.decode64(
    ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
  )
end
