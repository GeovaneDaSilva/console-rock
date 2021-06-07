module Analysis
  module Lookup
    # URL analysis service
    class Url < Base
      include ApiClients::ApiLimits::VirusTotal

      def call
        if current_analysis
          @analysis.analyzed!
          notify!
          current_analysis
        elsif @analysis.initialized?
          # Submit for analysis, check back later
          submit!
          requeue!
          notify!
          nil
        else
          requeue!
          nil
        end
      end

      private

      def current_analysis
        @current_analysis ||= Threats::Lookup::Url.new(@analysis.url).call
      end

      def submit!
        sleep rand(0..5) while api_limit.exceeded?
        api_limit.increment!

        api_client.post do |req|
          req.url "url/scan"
          req.params["apikey"] = api_key
          req.params["url"]    = @analysis.url
        end

        @analysis.submitted!
      end

      def requeue!
        return abandon! if @count >= MAX_RETRY

        ServiceRunnerJob.set(wait: next_count.minutes).perform_later(
          "Analysis::Lookup::Url", @analysis, next_count
        )
      end

      def api_client
        @api_client ||= ApiClients::VirusTotal.new.call
      end

      def api_key
        ENV["VIRUS_TOTAL_API_KEY"]
      end
    end
  end
end
