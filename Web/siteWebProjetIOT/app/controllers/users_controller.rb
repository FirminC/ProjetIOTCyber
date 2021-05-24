class UsersController < ApplicationController
  skip_before_action :authorized, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params.require(:user).permit(:username,        
    :password, :password_confirmation))
    session[:user_id] = @user.id
    if @user.save
      redirect_to '/welcome', notice: "User created"
    else
      render :new, status: :unprocessable_entity
    end
 end
end
