class User < ActiveRecord::Base
	has_many :posts, :order => "created_at DESC", :dependent => :destroy
	before_create :set_permalink_and_display_name
	has_attached_file :avatar, :styles => { :default => "115x115", :tiny => "30x30#" }, :storage => :s3, :s3_credentials => "#{RAILS_ROOT}/config/s3.yml", :s3_host_alias => "files.blitzentrapper.net", :url => ":s3_alias_url", :path => "avatars/:slug/:style.:extension", :default_url => "/images/avatars/btdefault.gif", :default_style => :default

  acts_as_authentic do |c|
  	c.require_password_confirmation = false
  	c.check_passwords_against_database = false
    c.validate_email_field = false
    c.validate_login_field = false
    c.validate_password_field = false
  end
  
  def after_oauth2_authentication
    json = oauth2_access.get('/me')

    if user_data = JSON.parse(json)
    	self.fbid = user_data['id']
      self.login = user_data['name']
      self.name = user_data['name']
      self.url = user_data['link']
    end
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
end
