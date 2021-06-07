module Analysis
  module Lookup
    # File analysis service
    class File < Base
      include ApiClients::ApiLimits::Opswat

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
      rescue Threats::Lookup::ApiLimitExceeded
        requeue!
      end

      private

      def current_analysis
        @current_analysis ||= Threats::Lookup::Hash.new(@analysis.upload.md5, true).call
      end

      def submit!
        raise Threats::Lookup::ApiLimitExceeded if api_limit.exceeded?

        api_limit.increment!

        payload = {
          body: Faraday::UploadIO.new(file.path, @analysis.upload.mime_type)
        }

        response = api_client.post("file", payload)
        @analysis.submitted! if response.success?
      end

      def file
        @file ||= Uploads::Downloader.new(@analysis.upload).call
      end

      def requeue!
        return abandon! if @count >= MAX_RETRY

        ServiceRunnerJob.set(wait: next_count.minutes).perform_later(
          "Analysis::Lookup::File", @analysis, next_count
        )
      end

      def api_client
        @api_client ||= ApiClients::Opswat.new(%i[multipart url_encoded]).call
      end

      def api_key
        ENV["OPSWAT_API_KEY"]
      end
    end
  end
end
