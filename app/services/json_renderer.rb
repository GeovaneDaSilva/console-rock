# Render a collection of URLs as a JSON file. URLs must not require authentication
class JsonRenderer
  FETCH_HEADERS = { "Accept" => "application/json" }.freeze
  TEMPFILE_ARGS = %w[json-renderer .json].freeze

  def initialize(*urls)
    @urls = urls

    @tempfile = Tempfile.new(TEMPFILE_ARGS)
  end

  def call
    @tempfile.tap do |tempfile|
      json = @urls.inject({}) do |memo, url|
        memo.update File.basename(url, ".json") => fetch_json(url)
      rescue Faraday::ClientError
        memo
      end

      tempfile << JSON.dump(json)
      tempfile.flush
    end
  end

  private

  def parse_url(url)
    uri = URI.parse(url)

    [uri.to_s[0..-uri.request_uri.size], uri.request_uri]
  end

  def fetch_json(url, headers: FETCH_HEADERS)
    base_uri, request_uri = parse_url(url)

    conn = init_faraday_connection(base_uri, headers)
    conn.get(request_uri).body
  end

  def init_faraday_connection(base, headers)
    Faraday.new(base, headers: headers) do |http|
      http.response :json

      http.adapter  Faraday.default_adapter
    end
  end
end
