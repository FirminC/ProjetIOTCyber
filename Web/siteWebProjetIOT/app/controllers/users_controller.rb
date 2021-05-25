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
    redirect_to '/welcome', notice: "Not Authorized" unless logged_in? and (is_admin? or @user.id == current_user.id)
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
    if @user.update(user_params)
      if !@user.initialized
        @user.initialized = true;
        @user.save
      end
      redirect_to users_path, notice: "User updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: "User was successfully destroyed." }
      format.json { head :no_content }
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
