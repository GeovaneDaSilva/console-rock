module Reports
  # Generate a JSON from a collection
  class JsonReporter < ReporterBase
    private

    def finalize
      @finalize ||= s3_file_object.presigned_url(:get, expires_in: 604_800)
    end

    def extract_values(element)
      JsonExtractor.new(element, attrs).call
    end

    def concat_values(values)
      JSON.pretty_generate(values)
    end

    def attrs
      @options[:attrs]
    end

    def filename
      "reports/#{DateTime.current.to_i}/#{options[:filename] || 'results'}.json"
    end

    def content_type
      "application/json"
    end
  end
end
