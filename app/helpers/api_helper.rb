# :nodoc
module ApiHelper
  def path(value)
    value.gsub(/\\/, "\\\\\\")
  end

  def conditional(operator, value)
    value.split(",").collect do |csv_value|
      send(operator.to_s, csv_value)
    end.join(",")
  end

  def is_equal_to(value)
    value
  end

  def is_not_equal_to(value)
    "!#{value}"
  end

  def contains(value)
    "*#{value}*"
  end

  def does_not_contain(value)
    "!*#{value}*"
  end

  def starts_with(value)
    "#{value}*"
  end

  def ends_with(value)
    "*#{value}"
  end

  def exists(value)
    value
  end
end
