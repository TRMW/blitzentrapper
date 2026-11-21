require 'net/http'

# Talks to Facebook Login (OAuth 2) for the "Continue with Facebook" button.
# See Facebook's docs on manually building a login flow:
# https://developers.facebook.com/docs/facebook-login/guides/advanced/manual-flow
class FacebookAuth
  class Error < StandardError; end

  API_VERSION = 'v21.0'.freeze
  DIALOG_URL = "https://www.facebook.com/#{API_VERSION}/dialog/oauth".freeze
  GRAPH_URL = "https://graph.facebook.com/#{API_VERSION}".freeze
  SCOPE = 'public_profile,email'.freeze

  def self.configured?
    app_id.present? && app_secret.present?
  end

  def self.app_id
    ENV['CONNECT_FACEBOOK_KEY']
  end

  def self.app_secret
    ENV['CONNECT_FACEBOOK_SECRET']
  end

  def self.authorize_url(redirect_uri:, state:)
    query = {
      client_id: app_id,
      redirect_uri: redirect_uri,
      state: state,
      scope: SCOPE,
      response_type: 'code'
    }
    "#{DIALOG_URL}?#{query.to_query}"
  end

  # Exchanges the code from the callback for the person's profile:
  # { 'id' => ..., 'name' => ..., 'email' => ... } plus 'access_token'.
  def self.fetch_user(code:, redirect_uri:)
    token = get_json('/oauth/access_token',
                     client_id: app_id,
                     client_secret: app_secret,
                     redirect_uri: redirect_uri,
                     code: code)['access_token']
    raise Error, 'Facebook returned no access token' if token.blank?

    get_json('/me', fields: 'id,name,email', access_token: token)
      .merge('access_token' => token)
  end

  def self.get_json(path, params)
    uri = URI("#{GRAPH_URL}#{path}")
    uri.query = params.to_query
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true,
                               open_timeout: 5, read_timeout: 5) do |http|
      http.get(uri.request_uri)
    end
    body = JSON.parse(response.body)
    unless response.is_a?(Net::HTTPSuccess)
      message = body.dig('error', 'message') || response.code
      raise Error, "Facebook #{path} failed: #{message}"
    end
    body
  rescue JSON::ParserError, SocketError, SystemCallError,
         Net::OpenTimeout, Net::ReadTimeout => e
    raise Error, "Facebook #{path} failed: #{e.class}: #{e.message}"
  end
  private_class_method :get_json
end
