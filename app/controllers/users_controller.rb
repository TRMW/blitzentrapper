class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:edit, :update]

  def show
    if @user = User.find_by_slug(params[:id])
    else
    	render_404
    end 
  end
   
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user]) || User.new(params[:user_session])
    @user.save do |result|
	    if @user.save
	      flash[:notice] = "Thanks for signing up!"
	      redirect_back_or_default user_path(@user)
	    else
	      unless @user.oauth2_token.nil? # log Facebook user in if they're not already in the system
	        @user = User.find_by_oauth2_token(@user.oauth2_token)
	        unless @user.nil?
	          UserSession.create(@user)
	          flash.now[:message] = "Welcome back!"
	          redirect_back_or_default user_path(@user)        
	        else
	          redirect_back_or_default root_path
	        end
	      else
	        render :action => :new
	      end
	    end
    end
  end

  def edit
    @user = current_user
  end
  
  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_back_or_default user_path(@user)
    else
      render :action => :edit
    end
  end
  
	def facebook_oauth_callback
	  if not params[:code].nil?
	    callback = url_for(:controller => :users, :action => 'facebook_oauth_callback')
	    url = URI.parse("https://graph.facebook.com/oauth/access_token?client_id=124824307554524&redirect_uri=#{callback}&client_secret=588ac5177103796ec2af6380c7c26857&code=#{CGI::escape(params[:code])}")
	    http = Net::HTTP.new(url.host, url.port)
	    http.use_ssl = (url.scheme == 'https')
	    tmp_url = url.path + "?" + url.query
	    request = Net::HTTP::Get.new(tmp_url)
	    response = http.request(request)
	    data = response.body
	    access_token = data.split("=")[1]
	    if access_token.blank?
	      flash[:notice] = 'An error occurred while connecting through Facebook, please try again later.' 
	    else
	      url = URI.parse("https://graph.facebook.com/me?access_token=#{CGI::escape(access_token)}")
	      http = Net::HTTP.new(url.host, url.port)
	      http.use_ssl = (url.scheme == 'https')
	      tmp_url = url.path + "?" + url.query
	      request = Net::HTTP::Get.new(tmp_url)
	      response = http.request(request)
	      user_data = response.body
	      user_data_obj = JSON.parse(user_data)
	      @user = User.new_or_find_by_oauth2_token(access_token, user_data_obj)
	
	      if @user.new_record?
	        # session[:user] = @user.attributes
	        user_session = UserSession.create(@user)
	        redirect_to(:action => 'edit')
	      else
	        user_session = UserSession.create(@user)
	        flash[:notice] = "Successfully logged in."
	        redirect_back_or_default root_url
	      end
	    end
	  end
	end
	
	def create_facebook
	  redirect_to("https://graph.facebook.com/oauth/authorize?client_id=124824307554524&redirect_uri=" + 
	    url_for(:controller => :users, :action => 'facebook_oauth_callback') + 
	    "&scope=offline_access")
	end

  #redirect old profile links
  def redirect
    redirect_to :action => 'show', :id => params[:id], :status => :moved_permanently
  end
  
  def redirect_by_id
  	@user = User.find(params[:id])
    redirect_to :action => 'show', :id => @user, :status => :moved_permanently
  end
end
