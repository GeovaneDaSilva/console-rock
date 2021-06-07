# Hunt Result scoped queries
module HuntResultable
  def of_type_within_date_range(type: :malicious, start_date:, end_date:)
    of_type(type: type).where(created_at: start_date..end_date)
  end

  def of_type_within_date_month(type: :malicious, date_month:)
    of_type_within_date_range(
      type: type, start_date: date_month.beginning_of_month, end_date: date_month.end_of_month
    )
  end

  def of_type_within_date_week(type: :malicious, date_week:)
    of_type_within_date_range(
      type: type, start_date: date_week.beginning_of_week, end_date: date_week.end_of_week
    )
  end

  def of_type_within_date_day(type: :malicious, date_day:)
    of_type_within_date_range(
      type: type, start_date: date_day.beginning_of_day, end_date: date_day.end_of_day
    )
  end

  def of_type(type:)
    hunt_results.joins(:hunt)
                .where(hunts: { indicator: Hunt.indicators[type] })
  end

  private

  def hunt_results
    raise NotImplementedError
  end
end
