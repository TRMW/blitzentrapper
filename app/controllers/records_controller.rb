class RecordsController < ApplicationController
  before_action :require_admin, :only => [ :new, :edit, :destroy ]

  def index
    @records = Record.all.with_attached_cover.order('release_date DESC')
  end

  def show
  	if Record.find_by_slug(params[:id])
	    @record = Record.find_by_slug(params[:id])
	  else Record.find(params[:id]) # find (unlike dynamic finders) raises RecordNotFound automatically
	  	@record = Record.find(params[:id])
	  	redirect_to :action => 'show', :id => @record.slug, :status => :moved_permanently
    end
  end

  def new
    @record = Record.new
    build_tracklist
  end

  def create
    @record = Record.new(params[:record].permit!)
    if @record.save
      flash[:notice] = "Successfully created record."
      redirect_to @record
    else
      render :action => 'new'
    end
  end

  def edit
    @record = Record.find_by_slug(params[:id])
    build_tracklist
  end

  def update
    @record = Record.find_by_slug(params[:id])
    if @record.update_attributes(params[:record].permit!)
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

  private

  def build_tracklist
    25.times do |i|
      track_number = @record.songs.length + i + 1
      @record.tracklistings.build(:track_number => track_number).build_song
  	end
  end
end
