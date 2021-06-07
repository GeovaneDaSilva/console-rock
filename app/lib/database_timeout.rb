# Enables an extended database operation by setting the statement_timeout to a custom value, in seconds.
# You can also pass 0, or :unlimited, to indicate that the query can run for as long as it wants.
# It also accepts duration objects, e.g., 1.hour
module DatabaseTimeout
  module_function

  def timeout(value_in_seconds)
    original = ActiveRecord::Base.connection.execute("SHOW statement_timeout").first["statement_timeout"]
    value = DatabaseTimeout.convert_to_seconds_string(value_in_seconds)
    ActiveRecord::Base.connection.execute("SET statement_timeout = '#{value}'")
    yield
  ensure
    ActiveRecord::Base.connection.execute("SET statement_timeout = '#{original}'")
  end

  def convert_to_seconds_string(val)
    case val
    when ActiveSupport::Duration
      "#{val}s"
    when Integer
      "#{val}s"
    when 0
      "0"
    when :unlimited
      "0"
    else
      "#{val}s"
    end
  end
end
