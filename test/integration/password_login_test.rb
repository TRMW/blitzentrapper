# frozen_string_literal: true

require "test_helper"

class PasswordLoginTest < ActionDispatch::IntegrationTest
  # Test vector from the phpass distribution's test.php.
  LEGACY_HASH = "$P$9IQRaTwmfeRo7ud9Fh4E2PdI0S3r.L0"

  test "logs in with the right password" do
    create_user("fan", password: "secret123")
    log_in("fan", "secret123")
    assert_redirected_to "/account"
  end

  test "rejects the wrong password" do
    create_user("fan", password: "secret123")
    log_in("fan", "wrong")
    assert_response :success
    assert_nil session_user
  end

  test "rejects any password for an account that has none" do
    user = create_user("facebook fan", fbid: "123")
    log_in("facebook fan", "anything")

    assert_nil session_user
    assert_nil user.reload.crypted_password
  end

  test "accepts and upgrades the right password for an imported account" do
    user = create_user("old fan", password: "placeholder")
    user.update_column(:crypted_password, LEGACY_HASH)

    log_in("old fan", "test12345")
    assert_redirected_to "/account"
    assert_not user.reload.legacy_password?
    assert user.valid_password?("test12345")
  end

  test "rejects the wrong password for an imported account" do
    user = create_user("old fan", password: "placeholder")
    user.update_column(:crypted_password, LEGACY_HASH)

    log_in("old fan", "test12346")
    assert_nil session_user
    assert_equal LEGACY_HASH, user.reload.crypted_password
  end

  private

  def create_user(login, attrs = {})
    user = User.new(attrs.merge(login: login))
    user.reset_persistence_token
    user.save!(validate: false)
    user
  end

  def log_in(login, password)
    post "/user_session",
         params: { user_session: { login: login, password: password } }
  end

  def session_user
    get "/account"
    controller.send(:current_user)
  end
end
