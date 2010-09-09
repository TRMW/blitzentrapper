class RecordsController < ApplicationController
  def index
    @records = Record.all(:order => 'release_date DESC')
    response.headers['Cache-Control'] = 'public, max-age=3600' # cache for one hour
  end
  
  def show
  	if Record.find_by_slug(params[:id])
	    @record = Record.find_by_slug(params[:id])
	    response.headers['Cache-Control'] = 'public, max-age=3600' # cache for one hour
	  else Record.find(params[:id]) # find (unlike dynamic finders) raises RecordNotFound automatically
	  	@record = Record.find(params[:id])
	  	redirect_to :action => 'show', :id => @record.slug, :status => :moved_permanently
    end
  end
  
  def new
    @record = Record.new
    15.times do |i|
    	track_number = @record.songs.length + i + 1
  		@record.tracklistings.build(:track_number => track_number).build_song
  	end
  end
  
  def create
    @record = Record.new(params[:record])
    if @record.save
      flash[:notice] = "Successfully created record."
      redirect_to @record
    else
      render :action => 'new'
    end
  end
  
  def edit
    @record = Record.find_by_slug(params[:id])
    15.times do |i|
    	track_number = @record.songs.length + i + 1
  		@record.tracklistings.build(:track_number => track_number).build_song
  	end
  end
  
  def update
    @record = Record.find_by_slug(params[:id])
    if @record.update_attributes(params[:record])
      flash[:notice] = "Successfully updated record."
      redirect_to @record
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @record = Record.find_by_slug(params[:id])
    @record.destroy
    flash[:notice] = "Successfully destroyed record."
    redirect_to records_url
  end
  
  #redirect rexx.html
  def redirect
    redirect_to :action => 'index', :status => :moved_permanently
  end
end
