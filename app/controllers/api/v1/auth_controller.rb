class Api::V1::AuthController < Api::V1::BaseController
  def test
    render json: {
      message: "Authentication API is working"
    }
  end

  def register
    user = User.new(user_params)

    if user.save
      render json: {
        message: "User registered successfully",
        user: {
          id: user.id,
          first_name: user.first_name,
          last_name: user.last_name,
          email: user.email,
          phone_number: user.phone_number,
          role: user.role
        }
      }, status: :created
    else
      render json: {
        errors: user.errors.full_messages
      }, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :password,
      :password_confirmation,
      :phone_number
    )
  end
end
