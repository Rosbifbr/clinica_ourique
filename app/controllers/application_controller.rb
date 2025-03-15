class ApplicationController < ActionController::Base
  # use the following command inside .devcontainer so you can use commands in the server: docker exec -it clinica_ourique-rails-app-1 bash

  before_action :authenticate_user!

  helper_method :current_user
  helper_method :user_signed_in?

  def user_signed_in?
    !current_user.nil?
  end

  private

  def current_user
    if session[:user_id]
      @current_user = User.find_by(id: session[:user_id])
    elsif
      @current_user = nil
    end
  end

  def authenticate_user!
    if current_user.nil?
      redirect_to sign_in_path, alert: "You need to sign in first."
    end
  end
end
