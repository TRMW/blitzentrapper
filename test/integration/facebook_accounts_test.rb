require 'test_helper'

class FacebookAccountsTest < ActionDispatch::IntegrationTest
  test 'old Facebook login links go to the help page' do
    get '/users/facebook-login'
    assert_redirected_to '/facebook-accounts'
    get '/users/facebook-callback', params: { code: 'abc' }
    assert_redirected_to '/facebook-accounts'
  end

  test 'the help page explains how to get back in' do
    get '/facebook-accounts'
    assert_response :success
    assert_select 'a[href=?]', '/password_resets/new'
    assert_select "a[href^='mailto:matt@blitzentrapper.net']"
  end

  test 'the forum no longer shows a Facebook button' do
    get '/forum'
    assert_select '.button--facebook', false
  end

  test 'an admin can make a set-password link for a Facebook account' do
    facebook_user = create_user('fb fan', fbid: '123')
    log_in_as(create_user('Matt', password: 'adminpass1'), 'adminpass1')

    post "/users/#{facebook_user.slug}/password_link"
    assert_response :success
    link = css_select('input#link').first['value']
    log_out

    get link
    assert_response :success
    patch URI(link).path.sub(%r{/edit\z}, ''),
          params: { password: 'newpassword1' }
    assert facebook_user.reload.valid_password?('newpassword1')
  end

  test 'other members cannot make set-password links' do
    facebook_user = create_user('fb fan', fbid: '123')
    log_in_as(create_user('someone', password: 'password12'), 'password12')

    post "/users/#{facebook_user.slug}/password_link"
    assert_redirected_to '/'
  end

  private

  def create_user(login, attrs = {})
    user = User.new(attrs.merge(login: login))
    user.reset_persistence_token
    user.save!
    user
  end

  def log_in_as(user, password)
    post '/user_session',
         params: { user_session: { login: user.login, password: password } }
    assert_redirected_to '/account'
  end

  def log_out
    get '/logout'
  end
end
