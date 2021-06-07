module TestResults
  # Represents a test result detail json/hash entry of the given type
  # REQ: must have "type" and "attributes" as below in json (usually "details")
  # Otherwise, the json will behave like a hash
  # { "type": "something", "attributes": json }
  class BaseJson
    IGNORED_ATTRS = %i[schema].freeze
    ORDER = %i[].freeze

    include Enumerable

    def self.new(hash)
      return hash.collect { |v| BaseJson.new(v) } if hash.is_a?(Array)

      @hash = hash

      working_hash = hash.deep_dup.with_indifferent_access

      lookup_klass = "#{parent}::#{working_hash[:type]&.delete(' ').try(:classify)}Json"
      return hash if working_hash.dig("type").blank? || working_hash.dig("attributes").nil?

      begin
        return lookup_klass.constantize.new(working_hash) if lookup_klass != name
      rescue NameError
        # Rails.logger.debug("No override for class #{lookup_klass}, continuing with #{name}")
      end

      super(cast_attributes!(working_hash))
    end

    def self.cast_attributes!(working_hash)
      resulting_hash = working_hash.deep_dup.with_indifferent_access
      working_hash[:attributes].each do |key, value|
        normalized_key = key.to_s.downcase
        resulting_hash[:attributes].delete(key)
        resulting_hash[:attributes][normalized_key] = if value.is_a?(Hash)
                                                        BaseJson.new(value)
                                                      elsif value.is_a?(Array)
                                                        value.take(10).collect do |v|
                                                          # Limit to 10 to prevent big boom
                                                          if v.is_a?(Hash)
                                                            BaseJson.new(v)
                                                          else
                                                            v
                                                          end
                                                        end
                                                      else
                                                        cast_value(normalized_key, value)
                                                      end
      end

      resulting_hash
    end

    def self.cast_value(key, value)
      case key
      when /occurances_since_last_reported/
        value.to_i
      when /last_visit/, "date", "time", /time_written/, /accessed/, /created/, /last_seen/,
        /modified/, /last_reported/, /timestamp/, /date_found/, /last_found/, /lastseen/,
        /firstseen/, /updatedat/, /installdate/, /event_time/
        value.blank? || value.to_s.scan(/\D\./).empty? ? Time.at(value.to_i) : Time.parse(value)
      when /hidden/
        if [true, false].include?(value)
          value.to_s.humanize
        else
          value.to_i.zero? ? "False" : "True"
        end
      when /size/
        value.to_i.to_s(:human_size)
      else
        value
      end
    end

    def initialize(hash)
      @hash = hash.with_indifferent_access
    end

    def type
      @type ||= @hash[:type]
    end

    def attributes
      @attributes ||= @hash[:attributes].slice(*keys)
    end

    def keys
      @keys ||= if key_order.blank?
                  @hash[:attributes].keys.collect(&:to_sym).without(*ignored_keys)
                else
                  other_keys = @hash[:attributes].keys.collect(&:to_sym) - key_order
                  (key_order + other_keys).without(*ignored_keys)
                end
    end

    def values
      @values ||= @hash[:attributes].values
    end

    def each
      attributes.each do |key, value|
        yield key, value
      end
    end

    def featurable_attributes
      attributes.reject do |_, value|
        value.is_a?(Array) || value.is_a?(Hash) || value.is_a?(BaseJson)
      end
    end

    def method_missing(method, *_args, &_blk)
      attributes[method] if keys.include?(method.to_sym)
    end

    def respond_to_missing?(method, *)
      keys.include?(method)
    end

    def as_json
      @hash
    end

    private

    def key_order
      @key_order ||= "#{self.class.name}::ORDER".constantize.collect(&:to_sym)
    end

    def ignored_keys
      @ignored_keys ||= "#{self.class.name}::IGNORED_ATTRS".constantize.collect(&:to_sym)
    end
  end
end
