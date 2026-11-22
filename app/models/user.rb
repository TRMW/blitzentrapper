class User < ActiveRecord::Base
  has_many :posts, -> { order "created_at DESC" }, dependent: :destroy
  has_many :topics, through: :posts, source: :postable, source_type: "Topic"
  before_create :set_permalink_and_display_name
  has_one_attached :avatar

  acts_as_authentic do |c|
    c.require_password_confirmation = false
    c.check_passwords_against_database = false

    # In version 3.4.0, released 2014-03-03, the default crypto_provider was changed from Sha512 to SCrypt:
    # https://github.com/binarylogic/authlogic/blob/master/UPGRADING.md#340
    c.transition_from_crypto_providers = [ Authlogic::CryptoProviders::Sha512 ]
    c.crypto_provider = Authlogic::CryptoProviders::SCrypt
  end

  def set_permalink_and_display_name
    self.slug = login.parameterize
    self.name = login
  end

  def to_param
    slug
  end

  validate :url_is_a_web_address, if: :url_changed?

  # The profile's website as a link target: http(s) only, with "http://"
  # added to bare addresses such as "example.com".
  def web_url
    return if url.blank?

    address = url.strip
    address = "http://#{address}" unless address.match?(/\A[a-z][a-z0-9+.-]*:/i)
    uri = URI.parse(address)
    address if uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    nil
  end

  PASSWORD_RESET_EXPIRY = 2.hours
  MINIMUM_PASSWORD_LENGTH = 8

  def self.with_email(email)
    return none if email.blank?

    where("LOWER(email) = ?", email.strip.downcase)
  end

  def password_reset_token
    PasswordResetToken.generate(self, expires_in: PASSWORD_RESET_EXPIRY)
  end

  def self.find_by_password_reset_token(token)
    PasswordResetToken.find_user(token)
  end

  def self.find_by_login_or_email(login)
    find_by_login(login) || find_by_email(login)
  end

  # Accounts imported from the old site still have phpass ("$P$") hashes:
  # check the password against that hash and, if it matches, re-hash it with
  # Authlogic. Accounts with no password at all (such as Facebook-only ones)
  # can't log in with a password.
  def honor_system_passwords(attempted_password)
    return false if crypted_password.blank?
    return valid_password?(attempted_password) unless legacy_password?
    return false unless Phpass.valid?(attempted_password, crypted_password)

    self.password = attempted_password
    true
  end

  def legacy_password?
    crypted_password.to_s.start_with?("$P$")
  end

  private

  def url_is_a_web_address
    errors.add(:url, "must be a web address, like https://example.com") if url.present? && web_url.nil?
  end
end
