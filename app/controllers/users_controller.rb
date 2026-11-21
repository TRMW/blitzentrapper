class UsersController < ApplicationController
  PASSWORD_LINK_EXPIRY = 7.days

  before_action :require_no_user, :only => [:new, :create]
  before_action :require_user, :only => [:edit, :update]
  before_action :require_admin, :only => [:destroy, :password_link]

  def show
    @user = User.find_by_slug(params[:id])
    return render_404 unless @user

    posts = @user.posts.includes(:postable).select(&:postable)
    @posts_by_postable = posts.group_by(&:postable)
    @first_post_ids = Post.first_post_ids_for(@posts_by_postable.keys)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if verify_recaptcha(model: @user) && @user.save
      flash[:notice] = 'Thanks for signing up!'
      redirect_back_or_default user_path(@user)
    else
      render :new
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes(user_params)
      flash[:notice] = 'Account updated!'
      redirect_back_or_default user_path(@user)
    else
      render :edit
    end
  end

  def destroy
    @user = User.find_by_slug(params[:id])
    @user.destroy
    redirect_to :root, alert: 'User deleted.'
  end

  # Lets an admin give someone who can't use the emailed reset (such as a
  # former Facebook login user with no email) a link to set a password.
  def password_link
    @user = User.find_by_slug(params[:id])
    return render_404 unless @user

    @link = edit_password_reset_url(
      PasswordResetToken.generate(@user, expires_in: PASSWORD_LINK_EXPIRY)
    )
  end

  #redirect old profile links
  def redirect_by_id
    user = User.find(params[:id])
    redirect_to :action => 'show', :id => user, :status => :moved_permanently
  end

  private

  def user_params
    params.require(:user).permit(:login, :email, :password, :avatar, :url, :location, :occupation, :interests, :dummy)
  end
end
