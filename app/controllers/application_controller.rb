class ApplicationController < ActionController::Base
  protect_from_forgery

  helper :all
  helper_method :current_user_session, :current_user, :is_admin, :is_band_member, :is_team_member, :is_current_user

  def not_found
    render_404
  end

  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end

    def is_admin
      current_user && (is_band_member(current_user) || is_team_member(current_user))
    end

    def is_band_member(user)
      user = user || current_user
      ['michael.james', 'marty', 'Mentok', 'earley', 'eearley', 'E. Earley', 'Brian Trapper', 'Ross McLochness'].include? user.login
    end

    def is_team_member(user)
      user = user || current_user
      ['Matt', 'Sara'].include? user.login
    end

    def is_current_user(user)
      current_user && current_user.login == user.login
    end

    def require_user
      unless current_user
        store_location
        redirect_to new_user_session_url, alert: 'You must be logged in to access that page'
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        redirect_to account_url, alert: 'You must be logged out to access that page'
        return false
      end
    end

    def require_admin
      unless is_admin
        redirect_to root_path, alert: 'You must be an admin in to access that page'
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

    def redirect_to_forum
      flash[:error] = "Sorry, that page is broken right now. Check out the forum instead?"
      redirect_to topics_url
    end

    def render_404
      render html: File.read(Rails.public_path.join('404.html')).html_safe, status: :not_found, layout: false
    end

  protected
    # taken from https://github.com/binarylogic/authlogic/blob/v4.4.2/README.md#2d-csrf-protection
    def handle_unverified_request
      fail ActionController::InvalidAuthenticityToken
    end
end
