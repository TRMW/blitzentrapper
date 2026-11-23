# Daily page view counters behind the traffic dashboard. See PageView for
# what each dimension means.
class TrafficCount < ActiveRecord::Base
  DIMENSIONS = %w[agent source referrer referrer_link search_term country landing page].freeze

  # Adds one to each { dimension => value } counter for the day, in a single
  # INSERT ... ON CONFLICT statement.
  def self.increment(counters, day: Date.current)
    rows = counters.map { |dimension, value| { day: day, dimension: dimension, value: value, count: 1 } }
    upsert_all(rows, unique_by: %i[day dimension value],
                     on_duplicate: Arel.sql("count = traffic_counts.count + 1"))
  end

  # Totals per value for one dimension over a date range, largest first:
  # [["Google", 42], ["Direct", 17], ...]
  def self.totals(dimension, days, limit: nil)
    where(dimension: dimension, day: days)
      .group(:value).order(Arel.sql("SUM(count) DESC"), :value).limit(limit)
      .sum(:count).to_a
  end

  # Daily totals for one dimension and value: { date => count }.
  def self.daily(dimension, value, days)
    where(dimension: dimension, value: value, day: days).group(:day).sum(:count)
  end
end
