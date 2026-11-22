source "https://rubygems.org"
ruby "3.4.13"

gem "rails", "~> 8.1.4"

gem "puma"
# Loaded without its Railtie so production can configure it
# (see config/environments/production.rb)
gem "rack-timeout", require: "rack/timeout/base"

# Authlogic crypto provider
gem "scrypt"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platform: :mri
  gem "dotenv-rails"
  # Rails' default RuboCop config; run with bin/lint
  gem "rubocop-rails-omakase", require: false
end

group :test do
  # Minitest 6 moved Minitest::Mock and #stub into this gem
  gem "minitest-mock"
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"

  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "web-console"
  gem "listen"
end


group :production do
  # Error tracking; inactive until SENTRY_DSN is set
  gem "sentry-rails"
  gem "sentry-ruby"
  gem "lograge"
end

# Rails 8 no longer bundles Sprockets; the app still serves its assets with it.
gem "sprockets-rails"
# Compiles the .scss files with Dart Sass (sass-rails used the deprecated
# LibSass C extension)
gem "dartsass-sprockets"
# Minifies Sprockets JS in production; unlike uglifier it parses modern
# JavaScript such as the esbuild bundle in app/assets/builds
gem "terser"
gem "pg", ">=  1.6.0"
gem "authlogic"
# json 2.10+ no longer loads ostruct (removed from default gems in Ruby 4)
gem "json", "~> 2.21"
gem "will_paginate"
gem "aws-sdk-s3", require: false
gem "rails_autolink"
gem "jquery-rails"
gem "acts_as_list"
# Builds app/javascript with esbuild (yarn build) into app/assets/builds
gem "jsbundling-rails"
gem "mini_magick", "~> 5.1"
# Rails 6.1+ resizes Active Storage variants through image_processing
# (using mini_magick here; see config.active_storage.variant_processor).
gem "image_processing", "~> 1.2"
gem "recaptcha"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false
