class UsersController < ApplicationController

  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:destroy]

  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    redirect_to root_url and return unless @user.activated?
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # Handle a successful save.
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your corgi account."
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      # Handle a successful save.
      flash[:success] = "You have successfully updated your profile"
      redirect_to user_url(@user)

    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "Poor corgi is deleted"
    redirect_to users_url
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end

    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "You didn't log in, bad corgi."
        redirect_to login_url
      end
    end

    #Confirms the correct user request
    def correct_user
      @user = User.find(params[:id])
      unless current_user?(@user)
        flash[:danger] = "You can't access this page, bad corgi."
        redirect_to(root_url)
      end
    end

    # Returns true if the given user is the current user.
    def current_user?(user)
      user == current_user
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
