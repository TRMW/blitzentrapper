# Be sure to restart your server when you modify this file.

# Specify a serializer for the signed and encrypted cookie jars.
# Valid options are :json, :marshal, and :hybrid.
# :hybrid reads the old Marshal-serialized cookies and rewrites them as JSON.
Rails.application.config.action_dispatch.cookies_serializer = :hybrid
