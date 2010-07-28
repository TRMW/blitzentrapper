class UserSession < Authlogic::Session::Base
	verify_password_method :bbpress
	oauth2_client_id      "124824307554524"
  oauth2_client_secret  "APPLICATION_SECRET"
  oauth2_site           "https://graph.facebook.com"
  oauth2_scope          "offline_access"
end