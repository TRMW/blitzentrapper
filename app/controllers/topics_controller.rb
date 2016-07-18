class TopicsController < ApplicationController
  before_filter :store_location, :only => [ :index, :show ]

  def index
    @topics = Topic.order('last_post_date DESC').paginate(:page => params[:page], :per_page => 20)
    @topic = Topic.new
    @topic.posts.build
    @user = User.new
  end

  def show
    if Topic.find_by_slug(params[:id])
      @topic = Topic.find_by_slug(params[:id])
      @post = Post.new
      @user = User.new
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def new
    @topic = Topic.new
    @topic.posts.build
  end

  def create
    if params[:topic][:title].include? 'bitcoin'
      current_user.nuke
      flash[:error] = 'Only spammers post about bitcoin here. You are nuked!'
      redirect_to root_path and return
    end

    @topic = Topic.new(params[:topic])
    if @topic.save
      flash[:notice] = 'Topic posted!'
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
      flash[:notice] = 'Topic updated.'
      redirect_to @topic
    else
      render :action => 'edit'
    end
  end

  def destroy
    @topic = Topic.find(params[:id])
    @topic.destroy
    flash[:error] = 'Topic deleted.'
    redirect_to topics_url
  end

  def search
    @query = params[:query].strip if params[:query]

    if @query and request.xhr?
      @topics = Topic.find(:all, :include => :posts, :conditions => ['title ILIKE ? AND posts.postable_id IS NOT NULL', "%#{@query}%"], :order => 'last_post_date DESC')
      render :partial => 'search', :layout => false
    end
  end

  # Redirect URLs like this one:
  # http://forum.blitzentrapper.net/topic.php?id=128
  def redirect_by_id
    topic = Topic.find(params[:id])
    redirect_to :action => 'show', :id => topic, :status => :moved_permanently
  end
end
