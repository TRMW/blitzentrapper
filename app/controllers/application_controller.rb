class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper :all
  helper_method :current_user_session, :current_user, :is_admin, :is_band_member, :is_team_member
  
  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end
    
    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end
    
    def is_admin
    	current_user && (['Matt', 'Sara', 'michael.james', 'marty', 'Mentok', 'earley', 'E. Earley', 'Brian Trapper', 'Ross McLochness'].include? current_user.login)
    end
    
    def is_band_member(user)
    	user = user || current_user
    	['michael.james', 'marty', 'Mentok', 'earley', 'E. Earley', 'Brian Trapper', 'Ross McLochness'].include? user.login
    end
    
    def is_team_member(user)
    	user = user || current_user
    	['Matt', 'Sara'].include? user.login
    end
        
    def require_user
      unless current_user
        store_location
        flash[:error] = "You must be logged in to access that page"
        redirect_to new_user_session_url
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:error] = "You must be logged out to access that page"
        redirect_to account_url
        return false
      end
    end
    
    def require_admin
    	unless is_admin
        flash[:error	] = "You must be an admin in to access that page"
        redirect_to root_path
        return false
      end
    end
    
    def store_location
      session[:return_to] = request.fullpath
    end
    
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
end
