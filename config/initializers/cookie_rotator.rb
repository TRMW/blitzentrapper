# The app ran on Rails 5.0 cookie defaults until 2026-11: encrypted cookies
# (including the session) used AES-256-CBC with keys derived via SHA1, and
# signed cookies used SHA1. The current defaults derive keys with SHA256 and
# encrypt with AES-256-GCM. These rotations let Rails read cookies written the
# old way and rewrite them the new way, so nobody is logged out. They can be
# removed once old sessions have expired.
Rails.application.config.after_initialize do
  action_dispatch = Rails.application.config.action_dispatch
  old_keys = ActiveSupport::KeyGenerator.new(
    Rails.application.secret_key_base, iterations: 1000, hash_digest_class: OpenSSL::Digest::SHA1
  )

  action_dispatch.cookies_rotations.tap do |cookies|
    cookies.rotate :encrypted,
      old_keys.generate_key(action_dispatch.encrypted_cookie_salt, ActiveSupport::MessageEncryptor.key_len("aes-256-cbc")),
      old_keys.generate_key(action_dispatch.encrypted_signed_cookie_salt),
      cipher: "aes-256-cbc", digest: "SHA1"
    cookies.rotate :signed, old_keys.generate_key(action_dispatch.signed_cookie_salt), digest: "SHA1"
  end
end
