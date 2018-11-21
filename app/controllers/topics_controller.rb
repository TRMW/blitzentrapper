class TopicsController < ApplicationController
  before_action :store_location, :only => [ :index, :show ]

  def index
    @topics = index_topics
    @topic = Topic.new
    @topic.posts.build
  end

  def show
    if Topic.find_by_slug(params[:id])
      @topic = Topic.find_by_slug(params[:id])
      @post = Post.new
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def new
    @topic = Topic.new
    @topic.posts.build
  end

  def create
    if topic_params[:title].include? 'bitcoin'
      current_user.nuke
      flash[:error] = 'Only spammers post about bitcoin here. You are nuked!'
      logger.info  "Nuked bitcoin poster: #{current_user.inspect}"
      redirect_to root_path and return
    end

    @topic = Topic.new(topic_params)
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
    if @topic.update_attributes(topic_params)
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

    if @query.blank?
      if request.xhr?
        @topics = index_topics
      else
        redirect_to topics_url and return
      end
    else
      @topics = Topic.includes(:posts).where('title ILIKE ? AND posts.postable_id IS NOT NULL', "%#{@query}%").references(:posts).order('last_post_date DESC').paginate(:page => params[:page], :per_page => 40)
    end

    if request.xhr?
      render :partial => 'search_results', :layout => false
    else
      @topic = Topic.new
      @topic.posts.build
      render :action => 'index'
    end
  end

  # Redirect URLs like this one:
  # http://forum.blitzentrapper.net/topic.php?id=128
  def redirect_by_id
    topic = Topic.find(params[:id])
    redirect_to :action => 'show', :id => topic, :status => :moved_permanently
  end

  private

  def topic_params
    # It's mandatory to specify the nested attributes that should be permitted.
    # If you use `permit` with just the key that points to the nested attributes hash,
    # it will return an empty hash.
    params.require(:topic).permit(:title, posts_attributes: [ :body, :user_id ])
  end

  def index_topics
    Topic.order('last_post_date DESC').paginate(:page => params[:page], :per_page => 20)
  end
end
