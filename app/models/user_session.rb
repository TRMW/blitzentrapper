class UserSession < Authlogic::Session::Base
	verify_password_method :bbpress
	oauth2_client_id      "124824307554524"
  oauth2_client_secret  "588ac5177103796ec2af6380c7c26857"
  oauth2_site           "https://graph.facebook.com"
  oauth2_scope          "offline_access,user_location"
end