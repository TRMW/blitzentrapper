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

  # Finds the account for a Facebook profile (see FacebookAuth.fetch_user),
  # creating one on first login. Existing accounts keep their login name.
  def self.find_or_create_from_facebook(user_data)
    user = find_by(fbid: user_data['id']) || new(fbid: user_data['id'])
    user.oauth2_token = user_data['access_token']
    email = user_data['email']
    if user.email.blank? && email.present? && !exists?(email: email)
      user.email = email
    end
    if user.new_record?
      name = user_data['name'].presence || 'Facebook user'
      user.login = available_login(name)
    end
    user.save
    user
  end

  def self.available_login(name)
    candidate = name
    suffix = 1
    while exists?(slug: candidate.parameterize) || exists?(login: candidate)
      suffix += 1
      candidate = "#{name} #{suffix}"
    end
    candidate
  end
  private_class_method :available_login

  def honor_system_passwords(attempted_password)
    if self.crypted_password.blank? || self.crypted_password.include?("$P$B")
      self.password = attempted_password
    else
      self.valid_password?(attempted_password)
    end
  end
end
