module ApiClients
  # :nodoc
  class ReversingLabs
    URL     = "https://ticloud01.reversinglabs.com".freeze
    HEADERS = {
      "Accept"     => "application/json",
      "User-Agent" => "#{I18n.t('application.name', default: 'ACME, Inc')} ReversingLabs Client v1"
    }.freeze

    def initialize(options = {})
      @username = options.fetch(:username, ENV["REVERSING_LABS_USERNAME"])
      @password = options.fetch(:password, ENV["REVERSING_LABS_PASSWORD"])
    end

    def call
      Faraday.new(URL, headers: HEADERS) do |http|
        http.basic_auth(@username, @password)

        http.params["format"] = "json"
        http.response :json

        http.adapter :net_http
      end
    end
  end
end
