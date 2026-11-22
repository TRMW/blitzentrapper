# Admin dashboard of where the site's traffic comes from, built from the
# daily TrafficCount counters (see PageView for how views are classified).
class TrafficController < ApplicationController
  PERIODS = [ 7, 30, 90 ].freeze

  before_action :require_admin

  def index
    @period = PERIODS.include?(params[:days].to_i) ? params[:days].to_i : 7
    @days = (Date.current - (@period - 1))..Date.current
    @previous_days = (@days.first - @period)..(@days.first - 1)

    agents = TrafficCount.totals("agent", @days).to_h
    @person_views = agents.delete("Person").to_i
    @bot_views = agents.values.sum
    @arrivals = TrafficCount.where(dimension: "source", day: @days).sum(:count)
    @previous_arrivals = TrafficCount.where(dimension: "source", day: @previous_days).sum(:count)

    @daily_people = TrafficCount.daily("agent", "Person", @days)
    @daily_arrivals = TrafficCount.where(dimension: "source", day: @days).group(:day).sum(:count)

    @sources = TrafficCount.totals("source", @days)
    @previous_sources = TrafficCount.totals("source", @previous_days).to_h
    @referrers = TrafficCount.totals("referrer", @days, limit: 25)
    @countries = TrafficCount.totals("country", @days, limit: 25)
    @landing_pages = TrafficCount.totals("landing", @days, limit: 25)
    @pages = TrafficCount.totals("page", @days, limit: 25)
    @not_found_pages = TrafficCount.totals("not_found_page", @days, limit: 25)
    @not_found_bot_pages = TrafficCount.totals("not_found_bot_page", @days, limit: 25)
    @not_found_agents = TrafficCount.totals("not_found_agent", @days)
    @not_found_links = TrafficCount.totals("not_found_link", @days, limit: 25)
    @not_found_total = @not_found_agents.sum(&:last)
    @bots = agents.sort_by { |name, count| [ -count, name ] }
  end
end
