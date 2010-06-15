class TopicsController < ApplicationController
	uses_tiny_mce  :only => [:index, :show, :new, :create, :edit, :update]
	before_filter :store_location, :only => [ :index, :show ]
	
  def index
    @topics = Topic.paginate :page => params[:page], :order => 'last_post_date DESC'
    @topic = Topic.new
    @topic.posts.build
    @user = User.new
  end
  
  def show
  	unless Topic.find_by_slug(params[:id]).nil?
	    @topic = Topic.find_by_slug(params[:id])
	    @post = Post.new
	    @user = User.new
	  else
	  	flash[:error] = "Topic not found."
    	redirect_to :action => 'index'
    end
  end
  
  def new
    @topic = Topic.new
    @topic.posts.build
  end
  
  def create
    @topic = Topic.new(params[:topic])
    if @topic.save
      flash[:notice] = "Topic posted!"
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
      flash[:notice] = "Topic updated."
      redirect_to @topic
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @topic = Topic.find(params[:id])
    @topic.destroy
    flash[:error] = "Topic deleted."
    redirect_to topics_url
  end
  
  #redirect old forum links
  def redirect
    redirect_to :action => 'show', :id => params[:id], :status => :moved_permanently
  end
  
  def search
  	@query = params[:query].strip if params[:query]
  	
  	if @query and request.xhr?
      @topics = Topic.find(:all, :conditions => ["title ILIKE ?", "%#{@query}%"], :order => "last_post_date DESC")     
      render :partial => "search", :layout => false
    end
	end
end