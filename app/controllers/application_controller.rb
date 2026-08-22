class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  stale_when_importmap_changes

  before_action :reject_inactive_session

  helper_method :current_user, :user_signed_in?

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.find_by(id: session[:user_id])
  end

  def user_signed_in?
    current_user.present?
  end

  def require_login
    unless user_signed_in?
      redirect_to login_path, alert: "Please log in to continue."
    end
  end

  def reject_inactive_session
    return unless current_user && !current_user.active?

    reset_session
    redirect_to login_path, alert: "Your account is not active."
  end
end
