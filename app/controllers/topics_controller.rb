class TopicsController < ApplicationController
	uses_tiny_mce  :only => [:index, :show, :new, :create, :edit, :update]
	before_filter :store_location, :only => [ :index, :show ]
	
  def index
    @topics = Topic.paginate :page => params[:page], :order => 'last_post_date DESC'
    @topic = Topic.new
    @topic.posts.build
  end
  
  def show
    @topic = Topic.find_by_slug(params[:id])
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
    @topic = Topic.find_by_slug(params[:id])
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
  
  #redirect old forum links
  def redirect
    redirect_to :action => 'show', :id => params[:id], :status => :moved_permanently
  end
  
  def search
  	@query = params[:query].strip if params[:query]
  	
  	if @query and request.xhr?
      @topics = Topic.find(:all, :conditions => ["title LIKE ?", "%#{@query}%"], :order => "title ASC")     
      render :partial => "search", :layout => false
    end
	end
end