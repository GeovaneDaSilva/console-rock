module ApiClients
  # :nodoc
  class VirusTotal
    URL = "https://www.virustotal.com/vtapi/v2/".freeze

    def initialize(request_opts = [])
      @request_opts = request_opts
    end

    def call
      Faraday.new(URL) do |http|
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
