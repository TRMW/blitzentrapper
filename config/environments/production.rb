require_relative '../../lib/cloudflare_proxy'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # secret_key_base: Rails 8 no longer reads `secrets.yml`. Set SECRET_KEY_BASE at runtime.
  # A placeholder is used during asset precompilation when unset (e.g. Docker build).
  config.secret_key_base = ENV["SECRET_KEY_BASE"] || ("0" * 64)

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory usage.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Compress JavaScript using Terser.
  config.assets.js_compressor = :terser

  # Do not fall back to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Store uploaded files on Amazon in production
  config.active_storage.service = :amazon

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Log at info level.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # In-process memory cache. Sufficient for Tumblr API response caching.
  # For shared/persistent caching, add Railway Redis and switch to :redis_cache_store.
  config.cache_store = :memory_store

  config.action_mailer.perform_caching = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # More concise logging so Papertrail doesn't choke
  config.lograge.enabled = true

  config.middleware.use CloudflareProxy
end
