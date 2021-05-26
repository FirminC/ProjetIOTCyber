class ApplicationController < ActionController::Base
    before_action :authorized
    before_action :change_password
    helper_method :current_user
    helper_method :logged_in?
    helper_method :is_admin?

    def current_user
        User.find_by(id: session[:user_id])
    end

    def logged_in?
        !current_user.nil?
    end

    def is_admin?
        !current_user.nil? and current_user.admin_permissions
    end

    def authorized
        redirect_to root_path, notice: "Not Logged in" unless logged_in?
    end

    def admin_authorized
        redirect_to root_path, notice: "Not Authorized" unless is_admin?
    end

    def change_password
        if logged_in?
            redirect_to edit_user_path(current_user), notice: "You need to change your password" unless current_user.initialized
        end
    end
end
