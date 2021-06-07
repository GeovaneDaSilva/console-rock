#!/usr/bin/env ruby

redis = Redis.new(url: ENV["ML_REDIS_URL"])

puts "Retrieving all sumitted PE headers and their results..."
all_md5s = redis.scan_each(pattern: "evaluate/pe/*").to_a.collect { |key| key.split("/").last.downcase }.uniq

results = []

all_md5s.each do |md5|
  begin
    submission = JSON.parse(redis.get("evaluate/pe/#{md5}".to_s))
    returned_value = JSON.parse(redis.get("evaluated/pe/#{md5}").to_s)

    results << {
      submitted_md5: md5,
      pe: submission,
      ml_prediction: returned_value
    }
  rescue StandardError
  end
end

puts results.to_json; nil
