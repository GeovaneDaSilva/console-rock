# One-way belongs to relation
class RedisRecordRelation
  include Redisable

  # related_record -> Object which responds to to_gid
  # max_relation_size -> Keeps redis queries under control
  def initialize(related_record, max_relation_size: 1_000)
    @related_record    = related_record
    @max_relation_size = max_relation_size
  end

  # Create the relation between the related_record and new redis_record
  def <<(redis_record)
    redis.lpush(base_key, redis_record.key)
    redis.ltrim(base_key, 0, @max_relation_size)
  end

  def create(attrs)
    redis_record = redis_record_klass.create(attrs)
    self << redis_record
    redis_record
  end

  def find(id)
    redis_record_klass.where(ids: Array.wrap(id)).first
  end

  def all(limit: nil)
    ids = redis.lrange(base_key, 0, [limit, @max_relation_size].compact.min)

    if ids.any?
      redis_record_klass.where(ids: ids.collect { |id| id.split("/").last })
    else
      []
    end
  end

  def first
    all(limit: 1).first
  end

  def destroy_all
    keys = redis.scan_each(match: "#{base_key}*").to_a.uniq
    redis.del(keys) if keys.any?
  end

  private

  def key(redis_record_id)
    "#{base_key}#{redis_record_id}"
  end

  def base_key
    @base_key ||= "#{@related_record.to_gid}/#{redis_record_klass.name.underscore}/"
  end

  def redis_record_klass
    @redis_record_klass ||= self.class.name.gsub("Relation", "").constantize
  end
end
