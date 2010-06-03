class User < ActiveRecord::Base
	has_many :posts, :order => "created_at DESC"
	before_create :set_permalink_and_display_name
	has_attached_file :avatar, :styles => { :default => "115x115", :tiny => "30x30#" }, :storage => :s3, :s3_credentials => "#{RAILS_ROOT}/config/s3.yml", :s3_host_alias => "files.blitzentrapper.net", :url => ":s3_alias_url", :path => "avatars/:slug/:style.:extension", :default_url => "/images/avatars/btdefault.gif", :default_style => :default

  acts_as_authentic do |c|
  	c.require_password_confirmation = false
  	c.check_passwords_against_database = false
  end
	
  def bbpress(attempted_password)
	  logger.debug "got here"
	  if self.crypted_password.include?("$P$B")
	  	logger.debug "got here too"
	    self.password=(attempted_password)
	    logger.debug "got here three aaand #{self.crypted_password}"
	  else self.valid_password?(attempted_password)
	  end
	end
    
  def set_permalink_and_display_name
    self.slug = login.parameterize
    self.name = login.parameterize
  end
  
  def self.set_avatar_filename
  	for user in User.all
		  if File.exists?('public/avatars/' + user.slug + '/original.jpg')
		  	user.avatar_file_name = 'original.jpg'
		  	user.save
		  elsif File.exists?('public/avatars/' + user.slug + '/original.gif')
		  	user.avatar_file_name = 'original.gif'
		  	user.save
		  elsif File.exists?('public/avatars/' + user.slug + '/original.png')
		  	user.avatar_file_name = 'original.png'
		  	user.save
		  end
		end
  end
  
  def to_param
    slug
  end
  
  def self.find_by_login_or_email(login)
    find_by_login(login) || find_by_email(login)
  end
end
