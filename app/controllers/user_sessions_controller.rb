class UserSessionsController < ApplicationController
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
#     target_user = User.find(params[:user_session][:login])
#     target_user.fix_bbpress_password
    
    if @user_session.save
      flash[:notice] = "Successfully logged in."
      render :action => 'new'
      # redirect_to root_url
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @user_session = UserSession.find
    @user_session.destroy
    flash[:notice] = "Successfully logged out."
    redirect_to root_url
  end
  
  def check_if_bbpress
    if user.crypted_password.include?("$P$B")
    	user.crypted_password = @user_session.password
    end
    logger.debug "#{@user_session.password} and #{user.crypted_password}"
  end
end
