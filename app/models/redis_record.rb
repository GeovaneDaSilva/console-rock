# Records which are stored in redis
# Should be volitile and expirable data
class RedisRecord
  include Redisable
  include GlobalID::Identification

  def self.inherited(child)
    relation_klass_name = child.name + "Relation"
    consts              = relation_klass_name.split("::".freeze)
    klass_name          = consts.pop

    object = consts.any? ? consts.join("::".freeze).constantize : Object
    object.const_set(klass_name, Class.new(RedisRecordRelation))
  end

  def self.find(id)
    data = redis.get("#{name.underscore}/#{id}")
    new(data) if data.present?
  end

  def self.where(ids: [])
    if ids.any?
      redis.mget(ids.collect { |id| "#{name.underscore}/#{id}" })
           .reject(&:nil?)
           .collect! { |value| new(value) }
    else
      []
    end
  end

  def self.all
    ids = redis.scan_each(match: "#{name.underscore}/*").to_a.uniq

    where(ids: ids.collect { |id| id.split("/").last })
  end

  def self.create(attrs, expires_in: 2.years)
    attrs.with_indifferent_access
    attrs[:id] ||= SecureRandom.uuid
    attrs[:created_at] ||= DateTime.current

    json = attrs.to_json
    redis.set("#{name.underscore}/#{attrs[:id]}", json, ex: expires_in.from_now.to_i)

    new(json)
  end

  def initialize(json)
    @attrs = JSON.parse(json).with_indifferent_access
  end

  def destroy
    redis.del(key)

    keys = redis.scan_each(match: "*#{key}*").to_a.uniq
    redis.del(*keys) unless keys.empty?
  end

  def to_json(*_args)
    @attrs.to_json
  end

  def as_json
    @attrs
  end

  def ==(other)
    key == other.key
  end

  def method_missing(method, *_args, &_blk)
    if @attrs[method]
      if method =~ /_at$/
        DateTime.parse(@attrs[method]).utc
      else
        @attrs[method]
      end
    else
      super
    end
  end

  def respond_to_missing?(method, *)
    @attrs[method].present?
  end
end
