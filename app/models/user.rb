class User < ActiveRecord::Base
  attr_accessible :login, :email, :url, :password
  has_many :posts, :order => "created_at DESC"
  before_create :set_permalink
  
  acts_as_authentic do |c|
  	c.validate_email_field = false
  	c.require_password_confirmation = false
  	c.check_passwords_against_database = false
  end
  
  def bbpress(attempted_password)
	  logger.debug "got here"
	  if self.crypted_password.include?("$P$B")
	  	logger.debug "got here too"
	    self.password=(attempted_password)
	    logger.debug "got here three aaand #{self.crypted_password}"
	  end
	end
  
  def set_permalink
    self.slug = login.parameterize
  end
  
  def to_param
    slug
  end
  
end
