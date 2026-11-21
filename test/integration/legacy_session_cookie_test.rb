# frozen_string_literal: true

require "test_helper"

# Session cookies written before the move to current Rails defaults
# (AES-256-CBC, SHA1-derived keys, Marshal) must still log the user in.
# See config/initializers/cookie_rotator.rb.
class LegacySessionCookieTest < ActionDispatch::IntegrationTest
  test "a session cookie from the old Rails 5.0 defaults still logs the user in" do
    user = User.new(login: "longtime fan", password: "secret123")
    user.reset_persistence_token
    user.save!(validate: false)

    cookies["_blitzen_session"] = legacy_session_cookie(
      "session_id" => SecureRandom.hex(16),
      "user_credentials" => user.persistence_token,
      "user_credentials_id" => user.id
    )

    get "/account"
    assert_response :success
    assert_equal user, controller.send(:current_user)
  end

  private

  # What Rails 5.0's EncryptedCookieJar wrote with config.load_defaults 5.0.
  def legacy_session_cookie(session)
    config = Rails.application.config.action_dispatch
    keys = ActiveSupport::KeyGenerator.new(
      Rails.application.secret_key_base, iterations: 1000, hash_digest_class: OpenSSL::Digest::SHA1
    )
    encryptor = ActiveSupport::MessageEncryptor.new(
      keys.generate_key(config.encrypted_cookie_salt, 32),
      keys.generate_key(config.encrypted_signed_cookie_salt),
      cipher: "aes-256-cbc", digest: "SHA1",
      serializer: ActiveSupport::MessageEncryptor::NullSerializer
    )
    encryptor.encrypt_and_sign(Marshal.dump(session))
  end
end
