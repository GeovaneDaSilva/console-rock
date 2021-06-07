module Analysis
  # URL analysis object
  class Url < Analyze
    attr_json_accessor :resource, :url
    delegate :clear?, :suspicious?, :compromise?, :permalink, :confidence, to: :results

    validates :url, presence: true, http_url: true

    def host
      URI.parse(url).host
    end

    private

    def results
      @results ||= VirusTotal::Url.new(Threats::Lookup::Url.new(url).call)
    end
  end
end
