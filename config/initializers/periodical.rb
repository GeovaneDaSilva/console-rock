# Convert words to time periods
class Periodical
  def self.table(key = :daily)
    case key
    when /hourly/
      1.hour
    when /daily/
      1.day
    when /weekly/
      7.days
    when /monthly/
      1.month
    when /quarterly/
      3.months
    when /bi_annually/
      6.months
    when /annually/
      1.year
    when /three_year/
      3.years
    else
      raise NotImplementedError, "Period #{key} not configured"
    end
  end
end
