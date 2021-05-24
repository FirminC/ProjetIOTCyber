class ApplicationController < ActionController::Base
    before_action :authorized
    helper_method :current_user
    helper_method :logged_in?

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
        redirect_to '/welcome' unless logged_in?
    end

    def admin_authorized
        redirect_to '/welcome' unless is_admin?
    end
end
