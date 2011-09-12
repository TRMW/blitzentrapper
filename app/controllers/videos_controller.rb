class VideosController < ApplicationController
	before_filter :store_location, :only => [ :index, :new ]
	
  # GET /videos
  def index
    @videos = Video.all
  end
  
  # GET /videos/new
  def new
    @video = Video.new
  end
  
  # POST /videos
  def create
    @video = Video.new(params[:video])

    if @video.save
      redirect_to('/home', :notice => 'Thanks for submitting your video! Stay tuned for more info.')
    else
      render :action => "new"
    end
  end
  
  def destroy
    @video = Video.find(params[:id])
    @video.destroy

    redirect_to(videos_url)
  end
end