source 'https://rubygems.org'
ruby '3.1.0'

gem 'rails', '~> 6.0.5'

# Following recommendations in this article:
# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server
gem 'puma'
gem 'rack-timeout'

# Rails barfs without this using Ruby 3
# https://stackoverflow.com/questions/71191685/visit-psych-nodes-alias-unknown-alias-default-psychbadalias
gem 'psych', '< 4'

# Authlogic crypto provider
gem 'scrypt'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'rails_stdout_logging' # makes `heroku local` show log output

  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen'
end


group :production do
  gem 'bugsnag'
  gem 'lograge'
  gem 'scout_apm'
end

gem 'sass-rails'
gem 'uglifier'
gem 'pg', '>=  1.6.0'
gem 'authlogic'
gem 'json'
gem 'will_paginate'
gem 'memcachier'
gem 'dalli'
gem 'aws-sdk-s3', require: false
gem 'rails_autolink'
gem 'jquery-rails'
gem 'acts_as_list'
gem 'webpacker', '~> 4.2'
gem 'mini_magick'
gem 'recaptcha'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false
