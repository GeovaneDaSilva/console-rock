module Credentials
  # :nodoc
  class CiscoUmbrella < Credential
    has_many :app_results, class_name: "Apps::CiscoUmbrellaResult", foreign_key: :credential_id,
      dependent: :destroy, inverse_of: :credential

    attr_json_accessor :keys, :organizations

    def base64
      Base64.encode64("#{app_key}:#{app_secret}").delete("\n")
    end
  end
end
