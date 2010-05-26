class SongsController < ApplicationController
  def index
    @songs = Song.all
  end
  
  def show
    @song = Song.find(params[:id])
  end
  
  def new
    @song = Song.new
  end
  
  def create
    @song = Song.new(params[:song])
    if @song.save
      flash[:notice] = "Successfully created song."
      redirect_to @song
    else
      render :action => 'new'
    end
  end
  
  def edit
    @song = Song.find(params[:id])
  end
  
  def update
    @song = Song.find(params[:id])
    if @song.update_attributes(params[:song])
      flash[:notice] = "Successfully updated song."
      redirect_to @song
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @song = Song.find(params[:id])
    @song.destroy
    flash[:notice] = "Successfully destroyed song."
    redirect_to songs_url
  end
end
