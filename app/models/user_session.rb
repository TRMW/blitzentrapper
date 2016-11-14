class UserSession < Authlogic::Session::Base
  verify_password_method :honor_system_passwords
end
