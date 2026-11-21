source "https://rubygems.org"
ruby "3.1.0"

gem "rails", "~> 6.1.7"
# concurrent-ruby 1.3.5 stopped loading Logger, which Rails < 7.1 relies on
# (NameError: ActiveSupport::LoggerThreadSafeLevel::Logger). Drop at Rails 7.1.
gem "concurrent-ruby", "< 1.3.5"

gem "puma"
# Loaded without its Railtie so production can configure it
# (see config/environments/production.rb)
gem "rack-timeout", require: "rack/timeout/base"

# Rails barfs without this using Ruby 3
# https://stackoverflow.com/questions/71191685/visit-psych-nodes-alias-unknown-alias-default-psychbadalias
gem "psych", "< 4"

# Authlogic crypto provider
gem "scrypt"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platform: :mri
  gem "dotenv-rails"
  # Rails' default RuboCop config; run with bin/lint
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "rails_stdout_logging" # makes `heroku local` show log output

  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "web-console"
  gem "listen"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen"
end


group :production do
  # Error tracking; inactive until SENTRY_DSN is set
  gem "sentry-rails"
  gem "sentry-ruby"
  gem "lograge"
  gem "scout_apm"
end

gem "sass-rails"
# Minifies Sprockets JS in production; unlike uglifier it parses modern
# JavaScript such as the esbuild bundle in app/assets/builds
gem "terser"
gem "pg", ">=  1.6.0"
gem "authlogic"
gem "json"
gem "will_paginate"
gem "aws-sdk-s3", require: false
gem "rails_autolink"
gem "jquery-rails"
gem "acts_as_list"
# Builds app/javascript with esbuild (yarn build) into app/assets/builds
gem "jsbundling-rails"
gem "mini_magick"
gem "recaptcha"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false
