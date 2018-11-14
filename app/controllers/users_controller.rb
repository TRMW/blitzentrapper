class UsersController < ApplicationController
  before_action :require_no_user, :only => [:new, :create]
  before_action :require_user, :only => [:edit, :update]
  before_action :require_admin, :only => [:nuke]

  def show
    @user = User.find_by_slug(params[:id]) or render_404
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    response = HTTParty.get("http://api.stopforumspam.org/api?ip=#{request.remote_ip}&email=#{@user.email}&username=#{ERB::Util.url_encode(@user.login)}&f=json").parsed_response
    if !params[:dummy].blank? ||
       @user.interests == 'Hello!' ||
       @user.interests.downcase.include?('quotes') ||
       @user.url.include?('viagra')
      flash[:error] = 'Something you entered here looks distinctly bot-like. Try again?'
      render :action => :new
    elsif response &&
          response['success'] == 1 &&
          response['ip']['appears'] + response['email']['appears'] > 0
      flash[:error] = "Sorry, your info showed up in stopforumspam.org's database, so we think you're a spammer."
      logger.info  "Stopped user from signing up based on stopforumspam.org info: #{request.remote_ip} => #{response['ip']['appears']} count, #{@user.email} => #{response['email']['appears']} count, #{@user.login} => #{response['username']['appears']} count"
      redirect_to root_path
    else
      if @user.save
        flash[:notice] = 'Thanks for signing up!'
        redirect_back_or_default user_path(@user)
      else
        render :action => :new
      end
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
      render :action => :edit
    end
  end

  def nuke
    if user = User.find_by_slug(params[:id])
      logger.info "#{current_user.name} is manually nuking user: #{user.inspect}"
      user.nuke
      flash[:notice] = 'User and all their posts deleted. Totally nuked!!'
    else
      logger.info "#{current_user.name} tried nuking user with slug '#{params[:id]}' that wasn't found"
      flash[:error] = "Hmm, couldn't find that user. Nuke someone else?"
    end
    redirect_to topics_path
  end

  def facebook_callback
    code = params['code']
    response = HTTParty.get(URI.encode("https://graph.facebook.com/oauth/access_token?client_id=#{ENV['CONNECT_FACEBOOK_KEY']}&client_secret=#{ENV['CONNECT_FACEBOOK_SECRET']}&code=#{code}&redirect_uri=#{facebook_callback_url}"))
    logger.info("Response from Facebook: #{response.body}")
    access_token = Rack::Utils.parse_nested_query(response.body)['access_token']

    if access_token
      json_user = JSON.parse HTTParty.get('https://graph.facebook.com/me?access_token=' + URI.escape(access_token)).response.body
      @user = User.new_or_find_by_oauth2_token(access_token, json_user)
      flash[:notice] = @user.new_record? ? 'Successfully logged in!' : 'Welcome back!'
    else
      flash[:error] = 'Facebook login failed. Please try again later.'
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
