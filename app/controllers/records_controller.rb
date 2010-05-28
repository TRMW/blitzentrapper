class RecordsController < ApplicationController
  def index
    @records = Record.all(:order => 'release_date DESC')
  end
  
  def show
    @record = Record.find(params[:id])
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
    @record = Record.find(params[:id])
    15.times do |i|
    	track_number = @record.songs.length + i + 1
  		@record.tracklistings.build(:track_number => track_number).build_song
  	end
  end
  
  def update
    @record = Record.find(params[:id])
    if @record.update_attributes(params[:record])
      flash[:notice] = "Successfully updated record."
      redirect_to @record
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @record = Record.find(params[:id])
    @record.destroy
    flash[:notice] = "Successfully destroyed record."
    redirect_to records_url
  end
  
  #redirect rexx.html
  def redirect
    redirect_to :action => 'index', :status => :moved_permanently
  end
end
