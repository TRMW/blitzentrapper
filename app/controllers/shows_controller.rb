class ShowsController < ApplicationController
	before_filter :store_location, :only => :show
	
  def index
    @shows = Show.today_forward
  end
  
  def month
  	@year = params[:year].to_i
  	@month = params[:month].to_i
    @shows = Show.by_month Date.new(@year, @month)
    @years = ['2009','2008','2007']
    @months = ['1','2','3','4','5','6','7','8','9','10','11','12',]
    render :archive
  end
  
  def year
  	@year = params[:year].to_i
    @shows = Show.by_year Date.new(@year)
    @years = ['2009','2008','2007']
    @months = ['1','2','3','4','5','6','7','8','9','10','11','12',]
    render :archive
  end
  
  def show
    @show = Show.find(params[:id])
    @show.posts.build
    15.times do |i|
    	track_number = @show.songs.length + i + 1
  		@show.setlistings.build(:track_number => track_number).build_song
  	end
  end
  
  def new
    @show = Show.new
    15.times do |i|
    	track_number = @show.songs.length + i + 1
  		@show.setlistings.build(:track_number => track_number).build_song
  	end
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
  
  #redirect tour.html
  def redirect
    redirect_to :action => 'index', :status => :moved_permanently
  end
  
  def search
  	@query = params[:query].strip if params[:query]
  	
  	if @query and request.xhr?
      @shows = Show.find(:all, :conditions => ["city LIKE ? OR venue LIKE ?", "%#{@query}%", "%#{@query}%"], :order => "date DESC")     
      render :partial => "search", :layout => false
    end
	end
end
