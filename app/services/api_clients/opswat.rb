module ApiClients
  # :nodoc
  class Opswat
    URL = "https://api.metadefender.com/v4/".freeze

    def initialize(request_opts = [])
      @request_opts = request_opts
    end

    def call
      Faraday.new(URL) do |http|
        http.headers["apikey"] = ENV["OPSWAT_API_KEY"]
        http.response :json

        @request_opts.each do |opt|
          http.request opt
        end

        http.options[:timeout] = 60

        http.adapter :net_http
      end
    end
  end
end
