# :nodoc
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # https://github.com/rails/rails/issues/34408#issuecomment-444219525
  def self.collection_cache_key(collection = all, timestamp_column = :updated_at)
    if collection.respond_to?(:total_count)
      "#{super}-#{collection.total_count}"
    else
      super
    end
  end

  def recently_updated?(more_recent_than: 5.seconds.ago)
    updated_at >= more_recent_than
  end

  def flipper_id
    "#{self.class.name}:#{id}"
  end
end
