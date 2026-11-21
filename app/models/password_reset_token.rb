# frozen_string_literal: true

# Signed, expiring tokens for password reset links. Nothing is stored in the
# database: the token carries the user id and a fingerprint of the user's
# current password and persistence token, so it stops working as soon as the
# password changes (making it single use) or the expiry passes.
module PasswordResetToken
  PURPOSE = :password_reset

  def self.generate(user, expires_in:)
    verifier.generate(
      [ user.id, fingerprint(user) ], expires_in: expires_in, purpose: PURPOSE
    )
  end

  def self.find_user(token)
    id, print = verifier.verified(token.to_s, purpose: PURPOSE)
    return unless id

    user = User.find_by(id: id)
    user if user && ActiveSupport::SecurityUtils.secure_compare(
      fingerprint(user), print.to_s
    )
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ArgumentError
    nil
  end

  def self.fingerprint(user)
    Digest::SHA256.hexdigest(
      "#{user.crypted_password}|#{user.persistence_token}"
    )[0, 32]
  end

  def self.verifier
    Rails.application.message_verifier(PURPOSE)
  end
end
