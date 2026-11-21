require 'test_helper'
require 'minitest/mock'

class FacebookLoginTest < ActionDispatch::IntegrationTest
  setup do
    @env = ENV.to_h.slice('CONNECT_FACEBOOK_KEY', 'CONNECT_FACEBOOK_SECRET')
    ENV['CONNECT_FACEBOOK_KEY'] = 'app-id'
    ENV['CONNECT_FACEBOOK_SECRET'] = 'app-secret'
  end

  teardown do
    %w[CONNECT_FACEBOOK_KEY CONNECT_FACEBOOK_SECRET].each do |key|
      ENV[key] = @env[key]
    end
  end

  test 'redirects to the Facebook login dialog with a state' do
    get '/users/facebook-login'
    location = URI(response.location)
    query = Rack::Utils.parse_query(location.query)

    assert_equal 'www.facebook.com', location.host
    assert_equal "/#{FacebookAuth::API_VERSION}/dialog/oauth", location.path
    assert_equal 'app-id', query['client_id']
    assert_equal 'http://www.example.com/users/facebook-callback',
                 query['redirect_uri']
    assert query['state'].present?
  end

  test 'shows an error when the app keys are missing' do
    ENV.delete('CONNECT_FACEBOOK_KEY')
    get '/users/facebook-login'
    assert_redirected_to '/login'
    assert_equal 'Facebook login failed. Please try again later.',
                 flash[:alert]
  end

  test 'creates an account on first Facebook login' do
    profile = facebook_profile('123', 'Eric Earley', 'eric@example.com')
    assert_difference -> { User.count }, 1 do
      log_in_with_facebook(profile)
    end

    user = User.find_by(fbid: '123')
    assert_equal 'Eric Earley', user.login
    assert_equal 'eric-earley', user.slug
    assert_equal 'eric@example.com', user.email
    assert_equal 'Thanks for signing up!', flash[:notice]
    assert_logged_in_as user
  end

  test 'logs an existing Facebook user back in without renaming them' do
    user = create_user('Old Name', fbid: '123')
    profile = facebook_profile('123', 'New Name', 'new@example.com')
    assert_no_difference -> { User.count } do
      log_in_with_facebook(profile)
    end

    user.reload
    assert_equal 'Old Name', user.login
    assert_equal 'new@example.com', user.email
    assert_equal 'Welcome back!', flash[:notice]
    assert_logged_in_as user
  end

  test 'picks a free login name and skips an email already in use' do
    create_user('Eric Earley', email: 'eric@example.com')
    log_in_with_facebook(facebook_profile('123', 'Eric Earley',
                                          'eric@example.com'))

    user = User.find_by(fbid: '123')
    assert_equal 'Eric Earley 2', user.login
    assert_nil user.email
  end

  test 'rejects a callback with the wrong state' do
    get '/users/facebook-login'
    FacebookAuth.stub(:fetch_user, ->(**) { flunk 'should not call' }) do
      get '/users/facebook-callback', params: { code: 'c', state: 'wrong' }
    end
    assert_redirected_to '/login'
  end

  test 'handles the person cancelling on Facebook' do
    get '/users/facebook-login'
    get '/users/facebook-callback',
        params: { error: 'access_denied', state: facebook_state }
    assert_redirected_to '/login'
    assert_equal 'Facebook login was cancelled.', flash[:alert]
  end

  test 'handles Facebook API errors' do
    get '/users/facebook-login'
    failing = ->(**) { raise FacebookAuth::Error, 'boom' }
    FacebookAuth.stub(:fetch_user, failing) do
      get '/users/facebook-callback',
          params: { code: 'c', state: facebook_state }
    end
    assert_redirected_to '/login'
  end

  private

  def facebook_profile(id, name, email)
    { 'id' => id, 'name' => name, 'email' => email,
      'access_token' => 'token' }
  end

  def facebook_state
    Rack::Utils.parse_query(URI(response.location).query)['state']
  end

  def log_in_with_facebook(profile)
    get '/users/facebook-login'
    state = facebook_state
    FacebookAuth.stub(:fetch_user, ->(**) { profile }) do
      get '/users/facebook-callback', params: { code: 'c', state: state }
    end
    assert_redirected_to '/'
  end

  def create_user(login, attrs = {})
    User.create!(attrs.merge(login: login, password: 'secret123'))
  end

  def assert_logged_in_as(user)
    get '/account'
    assert_response :success
    assert_equal user.id, controller.send(:current_user).id
  end
end
