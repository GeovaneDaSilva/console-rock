# Shared methods for redis records
module Redisable
  extend ActiveSupport::Concern

  class_methods do
    def redis
      Rails.application.config.redis_record_store
    end
  end

  def key
    @key ||= "#{self.class.name.underscore}/#{id}"
  end

  private

  def redis
    self.class.redis
  end
end
