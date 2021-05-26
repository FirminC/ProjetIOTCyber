class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update, :destroy]
  before_action :admin_authorized, except: [:edit, :update]
  skip_before_action :change_password, only: [:edit, :update]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def edit
    redirect_to root_path, notice: "Not Authorized" unless logged_in? and (is_admin? or @user.id == current_user.id)
  end

  def create
    @user = User.new(user_params)
    @user.password_digest = BCrypt::Password.create("TemporaryPassword")
    if @user.save
      redirect_to users_path, notice: "User created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    redirect_to root_path, notice: "Not Authorized" unless logged_in? and (is_admin? or @user.id == current_user.id)
    if @user.update(user_params)
      if !@user.initialized && !params[:password].nil?
        @user.initialized = true;
        @user.save
      end
      redirect_to users_path, notice: "User updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    admins = User.where(:admin_permissions => true)
    if !(admins.length == 1 and @user == admins.last)
      @user.destroy
      redirect_to users_path, notice: "User was successfully destroyed."
    else
      redirect_to users_path, notice: "Can't remove this user because he is the last admin"
    end
  end

  private
  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation, :admin_permissions)
  end
end
