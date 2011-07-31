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
    @user.save(:validate => true) do |result|
	    if @user.save(:validate => true)
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

  #redirect old profile links
  def redirect
    redirect_to :action => 'show', :id => params[:id], :status => :moved_permanently
  end
  
  def redirect_by_id
  	@user = User.find(params[:id])
    redirect_to :action => 'show', :id => @user, :status => :moved_permanently
  end
end
