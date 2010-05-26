class UserSession < Authlogic::Session::Base
	verify_password_method :bbpress
end