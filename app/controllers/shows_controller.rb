class ShowsController < ApplicationController
  before_filter :store_location, :only => :show
  before_filter :require_user, :only => :edit
  before_filter :require_admin, :only => [ :edit, :admin ]

  def index
    @shows = Show.today_forward
    expires_in 10.minutes, :public => true
  end

  def admin
    @shows = Show.all(:order => 'Date DESC')
  end

  def month
    @year = params[:year].to_i
    @month = params[:month].to_i
    @shows = Show.by_month Date.new(@year, @month)
    @years = get_years_array
    @months = get_months_array
    @title_date = Date.new(@year, @month).strftime('%B %Y')
    render :archive
  end

  def year
    @year = params[:year].to_i
    @shows = Show.by_year Date.new(@year)
    @years = get_years_array
    @months = get_months_array
    @title_date = Date.new(@year).strftime('%Y')
    render :archive
  end

  def show
    @show = Show.find(params[:id])
    @user = User.new
  end

  def new
    @show = Show.new
  end

  def create
    @show = Show.new(params[:show])
    if @show.save
      flash[:notice] = "Successfully created show."
      redirect_to @show
    else
      render :action => 'new'
    end
  end

  def edit
    @show = Show.find(params[:id])
  end

  def update
    @show = Show.find(params[:id])
    if @show.update_attributes(params[:show])
      flash[:notice] = "Successfully updated show."
      redirect_to @show
    else
      render :action => 'show'
    end
  end

  def destroy
    @show = Show.find(params[:id])
    @show.destroy
    flash[:notice] = "Successfully destroyed show."
    redirect_to shows_url
  end

  def edit_setlist
    @show = Show.find(params[:id])
    for setlisting in @show.setlistings
      unless setlisting.song_id?
        setlisting.build_song
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def cancel_setlist
    @show = Show.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def refresh
    flash[:notice] = Show.get_shows
    redirect_to shows_url
  end

  #redirect tour.html
  def redirect
    redirect_to :action => 'index', :status => :moved_permanently
  end

  def search
    query = params[:query].strip if params[:query]

    if query and request.xhr?
      # must use ILIKE for Heroku's PostgreSQL search to disregard lowercase/uppercase
      @shows = Show.find(:all, :conditions => ["city ILIKE ? OR venue ILIKE ?", "%#{query}%", "%#{query}%"], :order => "date DESC")
      render :partial => "search", :layout => false
    end
  end

  private

  def get_years_array
    years = []
    Show.get_archive_starting_year.downto(2007) { |y| years << y  }
    return years
  end

  def get_months_array
    return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
  end
end
