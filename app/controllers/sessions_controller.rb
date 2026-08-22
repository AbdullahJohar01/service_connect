class SessionsController < ApplicationController
  def new
    redirect_to root_path if user_signed_in?
  end

  def create
    user = User.find_by(email: params[:email])

    if user&.active? && user.authenticate(params[:password])
      session[:user_id] = user.id

      redirect_to root_path, notice: "Logged in successfully."
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    reset_session

    redirect_to root_path, notice: "Logged out successfully."
  end
end
