# Be sure to restart your server when you modify this file.

# Specify a serializer for the signed and encrypted cookie jars.
# Valid options are :json, :marshal, and :hybrid.
# Note: Using :marshal is not recommended for new apps. Use :json for best security.
# If upgrading from :marshal, use :hybrid temporarily to migrate existing cookies.
Rails.application.config.action_dispatch.cookies_serializer = :json
