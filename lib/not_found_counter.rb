# frozen_string_literal: true

# Counts page requests that end in a 404 for the "Pages not found" part of the
# traffic dashboard (/admin/traffic): which missing paths get hit, whether by
# people or crawlers, and which page or site linked there. It sits outside
# ActionDispatch::ShowExceptions so it also sees 404s from unknown routes and
# RecordNotFound. Like ApplicationController#count_page_view it keeps no IPs,
# skips admins (exclude_from_traffic cookie), and never breaks the response.
class NotFoundCounter
  ASSET_PATH = %r{\A/(assets|packs|rails/active_storage|uploads|system)/|\.(png|jpe?g|gif|svg|ico|css|js|map|woff2?|ttf|webp|txt|xml)\z}i

  def initialize(app)
    @app = app
  end

  def call(env)
    response = @app.call(env)
    count(env) if response[0].to_i == 404
    response
  end

  private
    def count(env)
      request = ActionDispatch::Request.new(env)
      return unless request.get?
      return if request.path.match?(ASSET_PATH)
      return if request.cookie_jar[ApplicationController::EXCLUDE_TRAFFIC_COOKIE].present?

      view = PageView.new(user_agent: request.user_agent, referrer: request.referer,
                          path: request.path, host: request.host,
                          ip: request.headers["X-Real-IP"].presence || request.remote_ip,
                          accept_language: request.headers["Accept-Language"])
      TrafficCount.increment(self.class.counters(view))
    rescue StandardError => e
      Rails.logger.warn("NotFoundCounter failed: #{e.class}: #{e.message}")
    end

  public

  # { dimension => value } counters for a 404:
  #   not_found_page      missing path requested by a person
  #   not_found_bot_page  missing path requested by a crawler
  #   not_found_agent     who asked: "Person" or the crawler's name
  #   not_found_link      "<linking page or site> → <missing path>", when
  #                       there's a referrer (our own pages by path, other
  #                       sites by name)
  def self.counters(view)
    path = view.path.truncate(200, omission: "")
    counts = { "not_found_agent" => view.agent }
    counts[view.person? ? "not_found_page" : "not_found_bot_page"] = path
    if view.referrer_host
      from = view.internal? ? (URI.parse(view.referrer).path.presence || "/" rescue "/") : view.referrer_name
      counts["not_found_link"] = "#{from} → #{path}".truncate(250, omission: "")
    end
    counts
  end
end
