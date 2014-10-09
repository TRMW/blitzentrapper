class User < ActiveRecord::Base
  has_many :posts, :order => "created_at DESC", :dependent => :destroy
  before_create :set_permalink_and_display_name
  has_attached_file :avatar,
                    :styles => { :default => "115x115", :tiny => "30x30#" },
                    :path => "avatars/:slug/:style.:extension",
                    :default_url => '/assets/avatars/btdefault.gif',
                    :default_style => :default
  validates_attachment_file_name :avatar, :matches => [/png\Z/i, /jpe?g\Z/i, /gif\Z/i]

  acts_as_authentic do |c|
    c.require_password_confirmation = false
    c.check_passwords_against_database = false
  end

  def bbpress(attempted_password)
    if self.crypted_password.include?("$P$B")
      self.password = attempted_password
    else
      self.valid_password?(attempted_password)
    end
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
    user
  end
end
