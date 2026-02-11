source 'https://rubygems.org'
ruby '3.4.8'

gem 'rails', '~> 8.0.0'

gem 'puma', '~> 6.0'
gem 'rack-timeout'

# Authlogic crypto provider
gem 'scrypt'

group :development, :test do
  gem 'debug', platform: :mri
  gem 'dotenv-rails'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'rails_stdout_logging' # makes `heroku local` show log output

  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
end


group :production do
  gem 'bugsnag'
  gem 'lograge'
  gem 'scout_apm'
end

gem 'sprockets-rails'
gem 'sassc-rails'
gem 'terser'
gem 'pg', '>= 1.6.0'
gem 'authlogic', '~> 6.6'
gem 'json'
gem 'will_paginate'
gem 'aws-sdk-s3', require: false
gem 'rails_autolink'
gem 'jquery-rails'
gem 'acts_as_list'
gem 'jsbundling-rails'
gem 'mini_magick'
gem 'recaptcha'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false
