# :nodoc
module Hibp
  # :nodoc
  module Services
    # :nodoc
    class Pull
      include PostApiCallProcessor

      URL = "https://haveibeenpwned.com/api/v3/".freeze

      # rubocop:disable Layout/LineLength
      def initialize(credential, service, account_id, email = nil, parameters = {}, first_pull = false, save_values = true)
        # rubocop:enable Layout/LineLength
        @credential = credential
        @service = service
        @account_id = account_id
        @email = email
        @parameters = parameters
        @first_pull = first_pull
        @save_values = save_values
      end

      def call
        return if @email&.include?("#EXT#") || !@credential.is_a?(Credentials::Hibp)

        request = HTTPI::Request.new
        request.url = url
        request.headers = { "hibp-api-key" => @credential.hibp_api_key }
        request.query = @parameters if @parameters.present?

        begin
          result = HTTPI.get(request)
          credential_is_working(result)
          if result.code == 200
            data = JSON.parse(result.raw_body)
            @save_values ? save(data) : data
          elsif @first_pull
            save(integration_success_message)
          end
        rescue Errno::ECONNRESET
          raise Hibp::ConnectionPeerResetError
        end
      end

      private

      def url
        url = "#{URL}#{@service}"
        url = "#{url}/#{@email}" if @email.present?
        url
      end

      def save(data)
        ServiceRunnerJob.set(queue: :utility).perform_later(
          "Hibp::SaveTemplates::Breaches",
          nil,
          @credential.id,
          data,
          @account_id,
          @email
        )
      end

      def integration_success_message
        [{
          "BreachDate" => DateTime.current.to_s,
          "email"      => "sample@test.com",
          "Name"       => "Integration Successful",
          "Title"      => "Integration Successful"
        }]
      end
    end
  end
end
