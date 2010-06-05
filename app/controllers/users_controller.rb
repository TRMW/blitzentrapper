class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:edit, :update]

  def show
    @user = User.find_by_slug(params[:id])
  end
   
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Thanks for signing up!"
      redirect_back_or_default user_path(@user)
    else
      render :action => :new
    end
  end

  def edit
    @user = current_user
  end
  
  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_back_or_default user_path(@user)
    else
      render :action => :edit
    end
  end
end
