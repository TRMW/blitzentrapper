# frozen_string_literal: true

# Error tracking. The sentry gems are only installed in production, and
# nothing is sent until SENTRY_DSN is set.
if defined?(Sentry) && ENV['SENTRY_DSN'].present?
  Sentry.init do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.environment = ENV.fetch('SENTRY_ENVIRONMENT') do
      ENV.fetch('RAILWAY_ENVIRONMENT_NAME', Rails.env)
    end
    config.release = ENV['RAILWAY_GIT_COMMIT_SHA']
    config.breadcrumbs_logger = %i[active_support_logger http_logger]
    # Errors only; no performance tracing.
    config.traces_sample_rate = 0.0
    # Don't send IPs, cookies or request bodies.
    config.send_default_pii = false
  end
end
