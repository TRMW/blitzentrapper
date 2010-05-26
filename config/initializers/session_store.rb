# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_blitzen_session',
  :secret      => 'ca463cdaa31977cfee640845487a739d530d503420537acfc4013eebf8c24307a28001afbf51f59b969c8bdef6196f4962babef93fedf0e9a2294f2ac339861c'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
