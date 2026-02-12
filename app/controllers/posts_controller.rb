class PostsController < ApplicationController
  # for the atom feed
  def index
    @posts = Post.order(created_at: :desc).limit(30)
    respond_to do |format|
      format.atom # feed.atom.builder
    end
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    if @post.save
      redirect_to @post.postable, notice: 'Posted!'
    else
      render :new
    end

  rescue ActiveRecord::RecordNotUnique
    # Try to manually increment ID here to fix conflict with manual IDs
    # from restored forum posts. Should be able to delete this check eventually.
    @post.id = Post.maximum(:id) + 1
    retry
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])

    if params[:topic]
      @post.postable.update(topic_params)
    end

    if @post.update(post_params)
      redirect_to @post.postable, notice: 'Post updated!'
    else
      render :edit
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to @post.postable, alert: 'Post deleted.'
  end

  private

  def topic_params
    params.require(:topic).permit(:title)
  end

  def post_params
    params.require(:post).permit(:body, :user_id, :postable_id, :postable_type)
  end
end
