class ShowsController < ApplicationController
  def index
    @shows = Show.find_all_by_festival_dupe # exclude dupes
  end
  
  def show
    @show = Show.find(params[:id])
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
    15.times do |i|
    	track_number = @show.songs.length + i + 1
  		@show.setlistings.build(:track_number => track_number).build_song
  	end
  end
  
  def update
    @show = Show.find(params[:id])
    if @show.update_attributes(params[:show])
      flash[:notice] = "Successfully updated show."
      redirect_to @show
    else
      render :action => 'edit'
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
end
