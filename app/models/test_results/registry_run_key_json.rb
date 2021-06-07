module TestResults
  # Represents a test result detail json/hash for Registry Run Key type
  class RegistryRunKeyJson < ProcessJson
    def self.cast_attributes!(working_hash)
      resulting_hash = working_hash.deep_dup.with_indifferent_access
      working_hash[:attributes].each do |key, value|
        normalized_key = key.to_s.downcase
        resulting_hash[:attributes].delete(key)
        resulting_hash[:attributes][normalized_key] = if key == "persistent_location"
                                                        persistent_value(value)
                                                      else
                                                        cast_value(normalized_key, value)
                                                      end
      end
      resulting_hash
    end

    def self.persistent_value(value)
      %w[key value value_data].collect { |k| value["registry_#{k}"] }.join("|")
    end
  end
end
