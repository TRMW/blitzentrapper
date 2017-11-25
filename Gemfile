source 'https://rubygems.org'
ruby '2.4.2'

gem 'rails', '5.1.4'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'rails_stdout_logging' # makes `heroku local` show log output
  # gem 'quiet_assets'
end


group :production do
  # This gem prevents deprecation warnings from Heroku
  # injected plugins
  # https://devcenter.heroku.com/articles/ruby-support#injected-plugins
  gem 'rails_12factor'
  gem 'bugsnag'
  gem 'lograge'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'uglifier'
end

gem 'pg'
gem 'thin'
gem 'authlogic'
gem 'hpricot'
gem 'json'
gem 'httparty'
gem 'feedjira'
gem 'will_paginate', '>= 3.0.pre4'
gem 'paperclip'
gem 'memcachier'
gem 'dalli'
gem 'aws-s3'
gem 'aws-sdk', '< 2.0'
gem 'dynamic_form'
gem 'rails_autolink'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'acts_as_list', :git => 'https://github.com/swanandp/acts_as_list.git'
gem 'scout_apm'
gem 'webpacker', '~> 3.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end
