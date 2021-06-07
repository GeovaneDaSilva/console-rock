module ApiClients
  # Alien Vault OTX HTTP client service using Faraday
  class AlienVault
    attr_reader :http

    URL     = "https://otx.alienvault.com".freeze
    HEADERS = {
      "Accept"     => "application/json",
      "User-Agent" => "#{I18n.t('application.name', default: 'ACME, Inc')} Alien Vault OTX Client v1"
    }.freeze

    def initialize(options = {})
      @api_key = options.fetch(:api_key, ENV["ALIEN_VAULT_OTX_API_KEY"])
    end

    def call
      Faraday.new(URL, headers: HEADERS) do |http|
        http.request :x_header_auth, name: "OTX-API-KEY", key: @api_key
        http.request :url_encoded

        http.response :json

        http.adapter :net_http
      end
    end

    # Custom middleware to handle authorization for this API. We can't use
    # the standard token header middleware because Alien Vault uses a custom
    # header
    class XHeaderAuth < Faraday::Middleware
      def initialize(app, options = {})
        super(app)

        @name = "X-#{options[:name]}"
        @key = options[:key]
      end

      def call(env)
        env[:request_headers][@name] = @key

        @app.call(env)
      end
    end

    Faraday::Request.register_middleware x_header_auth: XHeaderAuth
  end
end
