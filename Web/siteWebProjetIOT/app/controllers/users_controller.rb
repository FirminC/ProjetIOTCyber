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
    #set_user
    redirect_to root_path, notice: "Not Authorized" unless logged_in? and (is_admin? or @user.id == current_user.id)
    if current_user == @user 
      @otp_secret = ROTP::Base32.random
      @user.otp_secret = @otp_secret
      totp = ROTP::TOTP.new( @otp_secret, issuer: 'Safe-Truck' )
      @qr = RQRCode::QRCode.new(totp.provisioning_uri(@user.username)).as_svg(
        offset: 0,
        color: '000',
        shape_rendering: 'crispEdges',
        module_size: 6,
        standalone: true,
        viewbox: true
      )
    end
  end

  def create
    @user = User.new(user_params)
    @user.password_digest = BCrypt::Password.create("TemporaryPassword")
    if !User.find_by_username(@user.username) 
      if @user.save
        redirect_to users_path, notice: "User created"
      else
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:notice] = "User already exists"
      render :new
    end
  end

  def update
    otpEnabled = false;
    #set_user
    redirect_to root_path, notice: "Not Authorized" unless logged_in? and (is_admin? or @user.id == current_user.id)
    #to prevent disabling admin permissions of last admin
    admins = User.where(:admin_permissions => true)
    if (admins.length == 1 and @user == admins.last and user_admin_params[:admin_permissions] == "0") 
      redirect_to users_path, notice: "Can't change this permission because he is the last admin"
      return
    end
    if @user == current_user and !@user.initialized
      @otp_secret = user_params[:otp_secret]
      totp = ROTP::TOTP.new(@otp_secret, issuer: 'Safe-Truck')
      last_otp_at = totp.verify(params[:otp_attempt], drift_behind: 15)

      if last_otp_at
        otpEnabled = true
      else
        flash.now[:notice] = 'The code you provided was invalid!'
        redirect_to edit_user_path(@user)
        return
      end
    end

    if (!is_admin? and @user.update(user_params)) or (is_admin? and @user.update(user_admin_params))
      if !@user.initialized and !params[:user][:password].blank? and otpEnabled
        @user.initialized = true
        @user.last_otp_at = last_otp_at
        @user.otp_secret = @otp_secret
        @user.save
      end
      redirect_to users_path, notice: "User updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    #set_user
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
    params.require(:user).permit(:username, :password, :password_confirmation, :otp_secret, :otp_attempt)
  end

  def user_admin_params
    params.require(:user).permit(:username, :password, :password_confirmation, :admin_permissions)
  end
end
