class SessionsController < ApplicationController
  skip_before_action :authorized, only: [:new, :create, :welcome]
  skip_before_action :change_password, only: [:logout]

  def new
  end

  def create
    @user = User.find_by(username: params[:username])
      if @user && @user.authenticate(params[:password])
        session[:user_id] = @user.id
        redirect_to root_path
      else
        redirect_to '/login'
    end
  end

  def login
  end

  def logout
    session[:user_id] = nil
    redirect_to root_path, notice: "Logged out"
  end

  def welcome
    @trucks = Truck.all
    @json = @trucks.to_json(only: [:id, :hex_identifier, :name], methods: :lastTruckMapInfo)
  end

  def testApi
  end
end
