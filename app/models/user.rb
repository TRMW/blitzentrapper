class User < ActiveRecord::Base
	has_many :posts, :order => "created_at DESC"
	before_create :set_permalink_and_display_name

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
  
  def to_param
    slug
  end
  
  def self.find_by_login_or_email(login)
    find_by_login(login) || find_by_email(login)
  end
end
