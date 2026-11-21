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

  def honor_system_passwords(attempted_password)
    if self.crypted_password.blank? || self.crypted_password.include?("$P$B")
      self.password = attempted_password
    else
      self.valid_password?(attempted_password)
    end
  end
end
