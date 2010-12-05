class PostsController < ApplicationController
	uses_tiny_mce :only => [:new, :create, :edit, :update]
	named_scope :visible, :conditions => {:visible => true}

  # for the atom feed
  def index
    @posts = Post.find(:all, :order => 'created_at DESC', :limit => 30)  
    
    respond_to do |format|
      format.atom # feed.atom.builder
    end
  end
  
  def new
    @post = Post.new
  end
  
  def create
    @post = Post.new(params[:post])
    if @post.save
      flash[:notice] = "Posted!"
      respond_to do |format|
    		format.html { redirect_to @post.postable }
    		format.js
      end
    else
      render :action => 'new'
    end
  end
  
  def edit
    @post = Post.find(params[:id])
  end
  
  def update
    @post = Post.find(params[:id])
    if @post.update_attributes(params[:post])
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
  
  def redirect_feed
  	redirect_to :action => 'index', :format => 'atom', :status => :moved_permanently
  end
end
