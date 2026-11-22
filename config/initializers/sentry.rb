# frozen_string_literal: true

# Error tracking. The sentry gems are only installed in production, and
# nothing is sent until SENTRY_DSN is set.
if defined?(Sentry) && ENV["SENTRY_DSN"].present?
  Sentry.init do |config|
    config.dsn = ENV["SENTRY_DSN"]
    config.environment = ENV.fetch("SENTRY_ENVIRONMENT") do
      ENV.fetch("RAILWAY_ENVIRONMENT_NAME", Rails.env)
    end
    config.release = ENV["RAILWAY_GIT_COMMIT_SHA"]
    config.breadcrumbs_logger = %i[active_support_logger http_logger]
    # Performance tracing: sample 10% of requests by default (replaces Scout
    # APM). Override with SENTRY_TRACES_SAMPLE_RATE, e.g. 0 to turn it off.
    config.traces_sample_rate = ENV.fetch("SENTRY_TRACES_SAMPLE_RATE", "0.1").to_f
    # Don't send IPs, cookies or request bodies.
    config.send_default_pii = false
  end
end
