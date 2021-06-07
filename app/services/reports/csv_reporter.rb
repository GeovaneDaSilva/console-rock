module Reports
  # Generate A CSV from a collection
  class CsvReporter < ReporterBase
    private

    def finalize
      @finalize ||= s3_file_object.presigned_url(:get, expires_in: 604_800)
    end

    def extract_values(element)
      TabularExtractor.new(element, attrs, separator).call
    end

    def concat_values(values)
      [header, values.join("\n")].reject(&:blank?).join("\n")
    end

    def header
      @options[:header_values]&.join(separator)
    end

    def attrs
      @options[:attrs]
    end

    def separator
      @options[:separator] || ","
    end

    def filename
      "reports/#{DateTime.current.to_i}/#{options[:filename] || 'results'}.csv"
    end

    def content_type
      "text/csv"
    end
  end
end
