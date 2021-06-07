# Make json field values feel like real columns
module Encryptable
  extend ActiveSupport::Concern

  class_methods do
    def encrypt(column_name, options)
      encrypter = Module.new do
        options = options.with_indifferent_access

        key            = options.dig("key")
        iv_column_name = "#{column_name}_iv"
        # Read encrypted value as plain
        define_method(column_name) do
          value = super()

          iv = send(iv_column_name)
          return if value.blank? || iv.blank?

          Encryptor.decrypt(Base64.decode64(value), key: key, iv: Base64.decode64(iv))
        end

        # Write plain as encrypted value
        define_method("#{column_name}=") do |value|
          return super(nil) if value.blank?

          send("#{iv_column_name}=", generate_iv) if send(iv_column_name).blank?

          iv = send(iv_column_name)
          super(Base64.encode64(Encryptor.encrypt(value, key: key, iv: Base64.decode64(iv))))
        end
      end

      prepend encrypter
    end
  end

  private

  def generate_iv
    Base64.encode64(OpenSSL::Cipher.new("aes-256-gcm").tap(&:encrypt).random_iv)
  end
end
