# enables granular redis caching on queries
module QueryCachable
  # checks the cache for the current query state
  class QueryCache
    def initialize(context, query)
      @context = context
      @query = query
    end

    attr_reader :query, :context

    def available?
      @available ||= Rails.cache.exist?(key)
    end

    def key
      context.send("#{query}_key")
    end

    def clear!
      Rails.cache.delete(key)
    end
  end

  def self.cache(*method_names)
    method_names.each do |method_name|
      iv = "@#{method_name}"

      define_method method_name do |*args|
        return instance_variable_get(iv) if instance_variable_defined?(iv)

        key = send("#{method_name}_key")
        result = Rails.cache.fetch(key, expires_in: expiry) do
          super(*args)
        end
        instance_variable_set(iv, result)
      end

      define_method "#{method_name}_key" do
        [cache_key_prefix, self.class.name, key_prefix, method_name].flatten
      end
    end

    define_method :all_cachable_queries do
      method_names
    end
  end

  def all_queries_cached?
    all_query_caches.all?(&:available?)
  end

  def update_caches!
    all_cachable_queries.each { |query| send(query) }
    Rails.cache.write(cache_updated_at_key, Time.zone.now, { expires_in: expiry })
  end

  def cache_updated_at
    Rails.cache.read(cache_updated_at_key)
  end

  def clear_caches!
    all_query_caches.each(&:clear!)
  end

  def job_id
    return false if all_queries_cached?

    job = ServiceRunnerJob.set(queue: "reporting")
                          .perform_later("Queries::CacheUpdater", self.class.name, job_params)
    job.job_id
  end

  private

  def cache_key_prefix
    "v1/QueryCachable"
  end

  def cache_updated_at_key
    [cache_key_prefix, self.class.name, key_prefix, "cache_updated_at"]
  end

  def all_query_caches
    all_cachable_queries.map { |query| QueryCache.new(self, query) }
  end

  def expiry
    super
  end

  def key_prefix
    super
  end
end
