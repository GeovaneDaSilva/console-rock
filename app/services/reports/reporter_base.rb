module Reports
  # Base class for all reporters
  class ReporterBase
    attr_reader :key, :collection, :options, :results

    def initialize(key, collection, options = "{}")
      @key = key
      @collection = collection
      @options = (options.is_a?(String) ? JSON.parse(options) : options).to_options!
      @results = nil
    end

    def call
      extracted_values = extract_collection_values
      @results = concat_values(extracted_values)
      Rails.cache.write(key, finalize)
      finalize
    end

    alias generate call

    private

    # Override in subclass if post-processing must occur
    # i.e. Upload file to S3
    # Should likely be memoized
    def finalize
      @finalize ||= @results
    end

    # Override in subclass
    def extract_values(_element)
      raise NotImplementedError
    end

    def concat_values(_values)
      raise NotImplementedError
    end

    def extract_collection_values
      if collection.respond_to?(:find_each)
        iterate_relation
      else
        iterate_array
      end
    end

    def iterate_array
      collection.collect do |element|
        extract_values(element)
      end
    end

    def iterate_relation
      extracted_values = []

      collection.find_each(batch_size: 100) do |record|
        extracted_values << extract_values(record)
      end

      extracted_values
    end

    def iterate_search_results
      extracted_values = []
      query = collection

      until query.out_of_range?
        query.each { |element| extracted_values << extract_values(element) }

        query = query.klass.search(query.term, query.options.merge(page: query.current_page + 1))
      end

      extracted_values
    end

    def collection_type
      case collection
      when ActiveRecord::Relation
        collection.klass.name.demodulize
      when Array
        collection.first.class.name
      when Searchkick::Query
        collection.klass.name
      else
        "report"
      end
    end

    def bucket
      s3 = Aws::S3::Resource.new(region: ENV.fetch("AWS_REGION", "us-west-2"))
      s3.bucket(ENV.fetch("AWS_S3_BUCKET", "console-development"))
    end

    def s3_file_object
      bucket.put_object(
        key:                 filename,
        acl:                 "private",
        body:                @results,
        content_type:        content_type,
        content_disposition: %(attachment; filename="#{filename}")
      )
    end
  end
end
