class UsersController < ApplicationController
  FACEBOOK_LOGIN_FAILED =
    'Facebook login failed. Please try again later.'.freeze

  before_action :require_no_user, :only => [:new, :create]
  before_action :require_user, :only => [:edit, :update]
  before_action :require_admin, :only => [:destroy]

  def show
    @user = User.find_by_slug(params[:id]) or render_404
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if verify_recaptcha(model: @user) && @user.save
      flash[:notice] = 'Thanks for signing up!'
      redirect_back_or_default user_path(@user)
    else
      render :new
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes(user_params)
      flash[:notice] = 'Account updated!'
      redirect_back_or_default user_path(@user)
    else
      render :edit
    end
  end

  def destroy
    @user = User.find_by_slug(params[:id])
    @user.destroy
    redirect_to :root, alert: 'User deleted.'
  end

  def facebook_callback
    expected_state = session.delete(:facebook_state)
    if params[:error].present?
      return facebook_login_failed('Facebook login was cancelled.')
    end
    if expected_state.blank? || params[:state] != expected_state
      return facebook_login_failed
    end

    user_data = FacebookAuth.fetch_user(code: params[:code],
                                        redirect_uri: facebook_callback_url)
    @user = User.find_or_create_from_facebook(user_data)
    return facebook_login_failed unless @user.persisted?

    new_user = @user.saved_change_to_id?
    UserSession.create(@user, true) # true means "remember me"
    flash[:notice] = new_user ? 'Thanks for signing up!' : 'Welcome back!'
    redirect_back_or_default root_url
  rescue FacebookAuth::Error => e
    logger.warn("Facebook login failed: #{e.message}")
    facebook_login_failed
  end

  def facebook_request
    return facebook_login_failed unless FacebookAuth.configured?

    session[:facebook_state] = SecureRandom.hex(16)
    redirect_to FacebookAuth.authorize_url(
      redirect_uri: facebook_callback_url,
      state: session[:facebook_state]
    )
  end

  #redirect old profile links
  def redirect_by_id
    user = User.find(params[:id])
    redirect_to :action => 'show', :id => user, :status => :moved_permanently
  end

  private

  def facebook_login_failed(message = FACEBOOK_LOGIN_FAILED)
    flash[:alert] = message
    redirect_to login_url
  end

  def user_params
    params.require(:user).permit(:login, :email, :password, :avatar, :url, :location, :occupation, :interests, :dummy)
  end
end
