class User < ActiveRecord::Base
  has_many :posts, -> { order "created_at DESC" }, :dependent => :destroy
  has_many :topics, :through => :posts, :source => :postable, :source_type => 'Topic'
  before_create :set_permalink_and_display_name
  has_one_attached :avatar

  acts_as_authentic do |c|
    c.require_password_confirmation = false
    c.check_passwords_against_database = false

    # In version 3.4.0, released 2014-03-03, the default crypto_provider was changed from Sha512 to SCrypt:
    # https://github.com/binarylogic/authlogic/blob/master/UPGRADING.md#340
    c.transition_from_crypto_providers = [Authlogic::CryptoProviders::Sha512]
    c.crypto_provider = Authlogic::CryptoProviders::SCrypt
  end

  def set_permalink_and_display_name
    self.slug = login.parameterize
    self.name = login
  end

  def to_param
    slug
  end

  def self.find_by_login_or_email(login)
    find_by_login(login) || find_by_email(login)
  end

  def self.new_or_find_by_oauth2_token(access_token, user_data)
    user = User.find_by_oauth2_token(access_token)
    if user.blank?
      # if user already exists, just refresh their access token and info
      if user = User.find_by_fbid(user_data['id'])
        user.oauth2_token = access_token
        user.login = user_data['name']
        user.name = user_data['name']
        user.url = user_data['link']
      else
        user = User.new
        user.oauth2_token = access_token
        user.fbid = user_data['id']
        user.login = user_data['name']
        user.name = user_data['name']
        user.url = user_data['link']
        user.save
      end
    end
    UserSession.create(user, true) # true means "remember me"
    user
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
    crypted_password.to_s.start_with?('$P$')
  end
end
