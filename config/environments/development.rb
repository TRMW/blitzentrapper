# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

# Run rack-rewrite rules
config.middleware.insert_before(Rack::Lock, Rack::Rewrite) do
  # redirect any other domain to www.blitzentrapper.net
  r301 %r{.*}, 'http://www.blitzentrapper.net$&', :if => Proc.new {|rack_env|
    rack_env['SERVER_NAME'] != ( 'www.blitzentrapper.net' || 'blitzen.heroku.com' )
  }
  
  # remove any trailing slash
  r301 %r{^/(.*)/$}, '/$1'
end