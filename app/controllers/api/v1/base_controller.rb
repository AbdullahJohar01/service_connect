class Api::V1::BaseController < ActionController::API
  before_action :authenticate_user

  attr_reader :current_user

  private

  def authenticate_user
    header = request.headers["Authorization"]

    if header.blank?
      render json: { error: "Authorization token is missing" }, status: :unauthorized
      return
    end

    token = header.split(" ").last
    decoded = JwtService.decode(token)

    if decoded.nil?
      render json: { error: "Invalid or expired token" }, status: :unauthorized
      return
    end

    @current_user = User.find_by(id: decoded["user_id"])

    if @current_user.nil?
      render json: { error: "User not found" }, status: :unauthorized
    elsif !@current_user.active?
      render json: { error: "Account is not active" }, status: :forbidden
    end
  end

  def require_provider
    unless current_user&.provider?
      render json: { error: "Provider access required" }, status: :forbidden
    end
  end

  def require_admin
    unless current_user&.admin?
      render json: { error: "Admin access required" }, status: :forbidden
    end
  end
end
