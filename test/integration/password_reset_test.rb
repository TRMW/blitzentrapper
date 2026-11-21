# frozen_string_literal: true

require 'test_helper'

class PasswordResetTest < ActionDispatch::IntegrationTest
  setup do
    ActionMailer::Base.deliveries.clear
    @user = User.create!(
      login: 'resetter', email: 'Resetter@Example.com', password: 'oldpassword'
    )
  end

  test 'login page links to the reset form' do
    get '/login'
    assert_select 'a[href=?]', '/password_resets/new'
  end

  test 'requesting a reset emails a working link' do
    post '/password_resets', params: { email: ' resetter@example.COM ' }
    assert_redirected_to '/login'
    assert_equal 1, ActionMailer::Base.deliveries.size

    mail = ActionMailer::Base.deliveries.last
    assert_equal ['Resetter@Example.com'], mail.to
    path = mail.body.to_s[%r{/password_resets/[^\s]+/edit}]
    assert path, 'email should contain a reset link'

    get path
    assert_response :success
    assert_select 'strong', 'resetter'

    patch path.sub(%r{/edit\z}, ''), params: { password: 'newpassword1' }
    assert_redirected_to '/users/resetter'
    assert @user.reload.valid_password?('newpassword1')

    # The link is single use: the password change invalidates it.
    delete '/user_session'
    get path
    assert_redirected_to '/password_resets/new'
  end

  test 'unknown email gets the same response and no email' do
    post '/password_resets', params: { email: 'nobody@example.com' }
    assert_redirected_to '/login'
    assert_empty ActionMailer::Base.deliveries
  end

  test 'short passwords are rejected' do
    token = @user.password_reset_token
    patch "/password_resets/#{token}", params: { password: 'short' }
    assert_response :success
    assert @user.reload.valid_password?('oldpassword')
  end

  test 'tampered or expired tokens are rejected' do
    get '/password_resets/not-a-token/edit'
    assert_redirected_to '/password_resets/new'

    token = @user.password_reset_token
    travel User::PASSWORD_RESET_EXPIRY + 1.minute do
      get "/password_resets/#{token}/edit"
      assert_redirected_to '/password_resets/new'
    end
  end
end
