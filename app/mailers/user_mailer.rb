# frozen_string_literal: true

# Account emails sent to forum members.
class UserMailer < ApplicationMailer
  def password_reset(user)
    @user = user
    @url = edit_password_reset_url(user.password_reset_token)
    mail to: user.email, subject: "Reset your Blitzen Trapper forum password"
  end
end
