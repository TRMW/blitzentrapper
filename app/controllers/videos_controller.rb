class VideosController < ApplicationController
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
      redirect_to(videos_url, :notice => 'Video was successfully created.')
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