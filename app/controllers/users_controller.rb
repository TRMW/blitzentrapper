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
    if params[:user][:dummy]
      flash[:error] = "Please go away, bot."
      redirect_to :root
    @user = User.new(params[:user]) || User.new(params[:user_session])
    if @user.save
      flash[:notice] = "Thanks for signing up!"
      redirect_back_or_default user_path(@user)
    else
      render :action => :new
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
  
  def facebook_callback
		code = params['code']
		response = HTTParty.get(URI.encode("https://graph.facebook.com/oauth/access_token?client_id=124824307554524&client_secret=588ac5177103796ec2af6380c7c26857&code=#{code}&redirect_uri=#{facebook_callback_url}"))
		access_token = response.body.split("=")[1]
    json_user = JSON.parse HTTParty.get('https://graph.facebook.com/me?access_token=' + URI.escape(access_token)).response.body

    @user = User.new_or_find_by_oauth2_token(access_token, json_user)
		user_session = UserSession.create(@user)
		
    if @user.new_record?
      flash[:notice] = "Successfully logged in!"
    else
      flash[:notice] = "Welcome back!"
    end
    
    redirect_back_or_default root_url
  end
	
	def facebook_request
	  redirect_to("https://graph.facebook.com/oauth/authorize?client_id=124824307554524&scope=offline_access&redirect_uri=#{facebook_callback_url}")
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
