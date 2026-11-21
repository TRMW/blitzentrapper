# frozen_string_literal: true

# Lets people who forgot their password request an emailed reset link
# (see PasswordResetToken) and choose a new password from it.
class PasswordResetsController < ApplicationController
  # Most addresses only belong to one account, but a few people registered
  # more than once with the same email. Cap it so one request can't fan out.
  MAX_ACCOUNTS_PER_EMAIL = 5

  SENT_NOTICE = 'If an account uses that email address, we just sent it a ' \
                'link to reset the password. Check your inbox (and spam ' \
                'folder).'

  before_action :require_no_user
  before_action :require_mail_configured
  before_action :load_user_from_token, only: %i[edit update]

  def new; end

  def create
    unless verify_recaptcha
      flash.now[:alert] = 'Please confirm you are not a robot.'
      return render :new
    end

    send_reset_emails(params[:email].to_s)
    # Same response whether or not the address matched, so this form can't be
    # used to find out who has an account.
    redirect_to login_url, notice: SENT_NOTICE
  end

  def edit; end

  def update
    error = change_password(params[:password].to_s)
    if error
      flash.now[:alert] = error
      return render :edit
    end

    UserSession.create(@user, false)
    redirect_to user_url(@user),
                notice: 'Your password has been changed and you are logged in.'
  end

  private

  # Returns an error message, or nil once the password is saved.
  def change_password(password)
    if password.length < User::MINIMUM_PASSWORD_LENGTH
      return 'Your new password must be at least ' \
             "#{User::MINIMUM_PASSWORD_LENGTH} characters."
    end

    @user.password = password
    @user.save ? nil : @user.errors.full_messages.to_sentence
  end

  def require_mail_configured
    return if ApplicationMailer.configured?

    redirect_to login_url, alert: 'Password resets are not available yet.'
  end

  def load_user_from_token
    @token = params[:id]
    @user = User.find_by_password_reset_token(@token)
    return if @user

    redirect_to new_password_reset_url,
                alert: 'That reset link is invalid or has expired. ' \
                       'Please request a new one.'
  end

  def send_reset_emails(email)
    User.with_email(email).limit(MAX_ACCOUNTS_PER_EMAIL).each do |user|
      UserMailer.password_reset(user).deliver_now
    rescue StandardError => e
      # Don't reveal delivery failures to the visitor; report them instead.
      logger.error("Password reset email to user #{user.id} failed: #{e}")
      Sentry.capture_exception(e) if defined?(Sentry)
    end
  end
end
