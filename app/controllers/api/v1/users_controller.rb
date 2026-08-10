class Api::V1::UsersController < Api::V1::BaseController
  def me
    render json: {
      user: {
        id: current_user.id,
        first_name: current_user.first_name,
        last_name: current_user.last_name,
        email: current_user.email,
        role: current_user.role
      }
    }
  end
end
