# Update a given datetime column when given attributes change
# Partial cache keying when you want to ignore touching
# Example usage
# custom_cache_key :column, [:a_column, :another_column]
module CustomCacheKeyable
  extend ActiveSupport::Concern

  class_methods do
    def custom_cache_key(column, watched_attributes = [])
      self.custom_cache_keys ||= []
      self.custom_cache_keys << { column: column, watched_attributes: watched_attributes }
    end
  end

  included do
    cattr_accessor :custom_cache_keys
    before_save :update_custom_cache_keys
  end

  def update_custom_cache_keys
    updated_time = DateTime.current

    custom_cache_keys.each do |key|
      self[key[:column]] = updated_time if given_attributes_changed?(key[:watched_attributes])
    end
  end

  def given_attributes_changed?(attrs = [])
    keys = attributes_in_database.symbolize_keys.keys
    keys.size > (keys - attrs).size
  end
end
