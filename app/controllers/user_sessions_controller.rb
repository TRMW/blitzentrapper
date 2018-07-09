class UserSessionsController < ApplicationController
  before_action :require_no_user, :only => [:new, :create]

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params.require(:user_session).permit(:login, :password).to_h)
    @user_session.save do |result|
	    if @user_session.save
	      flash[:notice] = "Login successful!"
	      redirect_back_or_default account_url
	    else
	      render :action => :new
	    end
    end
  end

  def destroy
    if current_user_session
      current_user_session.destroy
      flash[:notice] = "Logout successful!"
    end
    redirect_back_or_default :root
  end
end
