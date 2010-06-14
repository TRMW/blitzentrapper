class UserSession < Authlogic::Session::Base
	verify_password_method :bbpress
	
  def self.oauth2_client
    OAuth2::Client.new("124824307554524", "588ac5177103796ec2af6380c7c26857", :site => "https://graph.facebook.com")
  end

  def self.oauth2_scope
  	'user_website'
  end
end