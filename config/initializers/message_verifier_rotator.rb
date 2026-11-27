# Signed ids that Rails 6 wrote (Active Storage blob and variant URLs, the
# avatar and cover image links that crawlers and old pages still request)
# were signed with keys derived via SHA1. The current defaults derive them
# with SHA256, so those URLs stopped verifying and returned 404. This lets
# every app message verifier, Active Storage's included, also accept the old
# keys. New messages are still signed the current way. Like the cookie
# rotations in cookie_rotator.rb, but these URLs never expire, so keep it.
Rails.application.message_verifiers.rotate(
  secret_generator: ->(salt) {
    ActiveSupport::KeyGenerator.new(
      Rails.application.secret_key_base, iterations: 1000, hash_digest_class: OpenSSL::Digest::SHA1
    ).generate_key(salt)
  }
)
