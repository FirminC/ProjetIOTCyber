class SessionsController < ApplicationController
  skip_before_action :authorized, only: [:new, :create, :welcome]
  before_action :admin_authorized, only: [:page_requires_admin]

  def new
  end

  def create
   @user = User.find_by(username: params[:username])
    if @user && @user.authenticate(params[:password])
       session[:user_id] = @user.id
       redirect_to '/welcome'
    else
       redirect_to '/login'
    end
   end

  def login
  end

  def logout
   session[:user_id] = nil
   redirect_to '/welcome'
  end

  def welcome

  end

  def page_requires_login
  end

  def page_requires_admin
  end
end
