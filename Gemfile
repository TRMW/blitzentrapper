source 'https://rubygems.org'
ruby '2.4.2'

gem 'rails', '5.2.0'

# Following recommendations in this article:
# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server
gem 'puma'
gem 'rack-timeout'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'rails_stdout_logging' # makes `heroku local` show log output
  # gem 'quiet_assets'

  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end


group :production do
  gem 'bugsnag'
  gem 'lograge'
  gem 'scout_apm'
end

gem 'sass-rails'
gem 'uglifier'
gem 'pg'
gem 'thin'
gem 'authlogic'
gem 'hpricot'
gem 'json'
gem 'httparty'
gem 'feedjira'
gem 'will_paginate', '>= 3.0.pre4'
gem 'paperclip', '6.0.0'
gem 'memcachier'
gem 'dalli'
gem 'aws-sdk-s3', require: false
gem 'dynamic_form'
gem 'rails_autolink'
gem 'jquery-rails'
gem 'acts_as_list', :git => 'https://github.com/swanandp/acts_as_list.git'
gem 'webpacker', '~> 3.0'
gem 'mini_magick'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false
