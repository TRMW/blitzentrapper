class UsersController < ApplicationController
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
    code = params['code']
    response = JSON.parse(URI.open("https://graph.facebook.com/oauth/access_token?client_id=#{ENV['CONNECT_FACEBOOK_KEY']}&client_secret=#{ENV['CONNECT_FACEBOOK_SECRET']}&code=#{code}&redirect_uri=#{facebook_callback_url}").read)
    logger.info("Response from Facebook: #{response}")
    access_token = response['access_token']

    if access_token
      json_user = JSON.parse(URI.open("https://graph.facebook.com/me?access_token=#{URI.escape(access_token)}").read)
      @user = User.new_or_find_by_oauth2_token(access_token, json_user)
      flash[:notice] = @user.new_record? ? 'Successfully logged in!' : 'Welcome back!'
    else
      flash[:alert] = 'Facebook login failed. Please try again later.'
    end

    redirect_back_or_default root_url
  end

  def facebook_request
    redirect_to("https://graph.facebook.com/oauth/authorize?client_id=#{ENV['CONNECT_FACEBOOK_KEY']}&redirect_uri=#{facebook_callback_url}")
  end

  #redirect old profile links
  def redirect_by_id
    user = User.find(params[:id])
    redirect_to :action => 'show', :id => user, :status => :moved_permanently
  end

  private

  def user_params
    params.require(:user).permit(:login, :email, :password, :avatar, :url, :location, :occupation, :interests, :dummy)
  end
end
