class PostsController < ApplicationController
  # for the atom feed
  def index
    @posts = Post.order('created_at DESC').limit(30)
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
      flash[:notice] = "Posted!"
      respond_to do |format|
        format.html { redirect_to @post.postable }
        format.js
      end
    else
      render :action => 'new'
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

    if topic_params
      @post.postable.update_attributes(topic_params)
    end

    if @post.update_attributes(post_params)
      flash[:notice] = "Post updated!"
      redirect_to @post.postable
    else
      render :action => 'edit'
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    flash[:error] = "Post deleted."
    redirect_to @post.postable
  end

  private

  def topic_params
    params.require(:topic).permit(:title)
  end

  def post_params
    params.require(:post).permit(:body)
  end
end
