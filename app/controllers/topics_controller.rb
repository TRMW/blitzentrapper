class TopicsController < ApplicationController
  def index
    @topics = Topic.all
    @topic = Topic.new
    @topic.posts.build
  end
  
  def show
    @topic = Topic.find(params[:id])
    @post = Post.new
  end
  
  def new
    @topic = Topic.new
  end
  
  def create
    @topic = Topic.new(params[:topic])
    if @topic.save
      flash[:notice] = "Successfully created topic."
      redirect_to @topic
    else
      render :action => 'new'
    end
  end
  
  def edit
    @topic = Topic.find(params[:id])
  end
  
  def update
    @topic = Topic.find(params[:id])
    if @topic.update_attributes(params[:topic])
      flash[:notice] = "Successfully updated topic."
      redirect_to @topic
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @topic = Topic.find(params[:id])
    @topic.destroy
    flash[:notice] = "Successfully destroyed topic."
    redirect_to topics_url
  end
end