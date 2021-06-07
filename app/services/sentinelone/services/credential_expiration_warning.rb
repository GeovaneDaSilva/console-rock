# :nodoc
module Sentinelone
  # :nodoc
  module Services
    # :nodoc
    class CredentialExpirationWarning
      def initialize
        tmp = App.where(report_template: "sentinelone").first
        @app_id = tmp.id unless tmp.nil?
        url = "http://2928012.hs-sites.com/knowledge/configuring-the-sentinelone-app"
        @text = "Your stored credential is about to expire.  "\
          "Please follow the renewal process given at #{url}"
      end

      def call
        expiring_credentials.each do |cred|
          account = cred.account
          next if account.billing_account.paid_thru < DateTime.current

          err = Apps::SentineloneResult.new(
            app_id:  @app_id,
            details: message
          )
          next unless err.new_record?

          err.assign_attributes(
            customer_id:    cred.account_id,
            verdict:        :malicious,
            value:          "Credential Expiration on #{cred.expiration.to_date}",
            value_type:     "",
            credential_id:  cred.id,
            detection_date: DateTime.current,
            account_path:   cred.account.path
          )
          err.save
        end
      end

      private

      def expiring_credentials
        @expiring_credentials ||= Credentials::Sentinelone.where("expiration < ?", 7.days.from_now)
      end

      def message
        @message ||= {
          "type"       => "SentineloneError",
          "attributes" => {
            description: @text
          }
        }
      end
    end
  end
end
