# Converts app config form objects to usable JSON
module Configable
  def cast_value(val)
    case val
    when Hash
      cast_hash(val)
    when Array
      val.collect { |v| cast_value(v) }.reject(&:blank?)
    when String
      cast_string(val)
    else
      val
    end
  end

  def cast_hash(hash)
    hash.keys.each do |k|
      if k =~ /_to_array$/
        hash[k.gsub(/_to_array$/, "")] = hash[k].split("\r\n")
        hash.delete(k)
      end
    end

    hash.each do |k, v|
      hash[k] = cast_value(v)
    end

    return nil if hash["_destroy"] == true

    hash.delete("_destroy")

    hash.reject { |_, v| v.nil? || v == "" || v == {} }
  end

  def cast_string(string)
    if %w[true].include?(string)
      true
    elsif %w[false].include?(string)
      false
    elsif string.match?(/^\d+$/)
      string.to_i
    else
      string
    end
  end
end
