class UsersController < ApplicationController
  PASSWORD_LINK_EXPIRY = 7.days
  # People take longer than this to fill in the signup form; bots that post
  # it straight after loading it don't.
  MINIMUM_SIGNUP_SECONDS = 3

  before_action :require_no_user, only: [ :new, :create ]
  before_action :require_user, only: [ :edit, :update ]
  before_action :require_admin, only: %i[destroy password_link]

  def show
    @user = User.find_by_slug(params[:id])
    return render_404 unless @user

    posts = @user.posts.includes(:postable).select(&:postable)
    @posts_by_postable = posts.group_by(&:postable)
    @first_post_ids = Post.first_post_ids_for(@posts_by_postable.keys)
  end

  def new
    @user = User.new
    @signup_started_at = signup_timer
  end

  def create
    @user = User.new(user_params)
    if signup_looks_automated?
      @user.errors.add(:base, "Sorry, that signup looked automated. Please try again.")
      @signup_started_at = signup_timer
      render :new
    elsif verify_recaptcha(model: @user) && @user.save
      flash[:notice] = "Thanks for signing up!"
      redirect_back_or_default user_path(@user)
    else
      @signup_started_at = signup_timer
      render :new
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      flash[:notice] = "Account updated!"
      redirect_back_or_default user_path(@user)
    else
      render :edit
    end
  end

  def destroy
    @user = User.find_by_slug(params[:id])
    @user.destroy
    redirect_to :root, alert: "User deleted."
  end

  # Lets an admin give someone who can't use the emailed reset (such as a
  # former Facebook login user with no email) a link to set a password.
  def password_link
    @user = User.find_by_slug(params[:id])
    return render_404 unless @user

    @link = edit_password_reset_url(
      PasswordResetToken.generate(@user, expires_in: PASSWORD_LINK_EXPIRY)
    )
  end

  # redirect old profile links
  def redirect_by_id
    user = User.find(params[:id])
    redirect_to action: "show", id: user, status: :moved_permanently
  end

  private

  def signup_timer
    signup_timer_verifier.generate(Time.current.to_i, expires_in: 1.day)
  end

  def signup_timer_verifier
    Rails.application.message_verifier("signup_timer")
  end

  # Bots fill in the hidden honeypot field, post the form without the timer
  # the signup page adds, or post it within seconds of loading it.
  def signup_looks_automated?
    reason =
      if params[:contact_me_by_fax_only].present?
        "honeypot"
      elsif (started_at = signup_timer_verifier.verified(params[:signup_started_at].to_s)).nil?
        "missing_timer"
      elsif Time.current.to_i - started_at < MINIMUM_SIGNUP_SECONDS
        "too_fast"
      end
    Rails.logger.info("Blocked automated signup (#{reason}) from #{request.remote_ip}") if reason
    reason.present?
  end

  def user_params
    params.require(:user).permit(:login, :email, :password, :avatar, :url, :location, :occupation, :interests)
  end
end
