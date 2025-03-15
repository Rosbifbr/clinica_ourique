class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :new, :create, :destroy ]

  def new
  end

  def create
    user = User.find_by(name: params[:name])
    if user && user.password == params[:password]  # Simplified password check
      session[:user_id] = user.id
      redirect_to root_path, notice: "Signed in successfully!"
    else
      flash.now[:alert] = "Invalid name or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to sign_in_path, notice: "Signed out successfully!"
  end
end
