class Api::V1::AuthController < Api::V1::BaseController
  skip_before_action :authenticate_user,
                    only: [
                      :test,
                      :register,
                      :login,
                      :refresh,
                      :logout,
                      :forgot_password,
                      :reset_password
                    ]

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

  def login
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      access_token = JwtService.encode_access_token(user.id)
      refresh_token = JwtService.generate_refresh_token

      user.refresh_tokens.create!(
        token_digest: JwtService.digest_refresh_token(refresh_token),
        expires_at: JwtService.refresh_token_expiry
      )

      render json: {
        message: "Login successful",
        access_token: access_token,
        refresh_token: refresh_token,
        user: {
          id: user.id,
          first_name: user.first_name,
          last_name: user.last_name,
          email: user.email,
          phone_number: user.phone_number,
          role: user.role
        }
      }, status: :ok
    else
      render json: {
        error: "Invalid email or password"
      }, status: :unauthorized
    end
  end

  def refresh
    refresh_token = params[:refresh_token]

    if refresh_token.blank?
      render json: {
        error: "Refresh token is required"
      }, status: :unauthorized
      return
    end

    token_digest = JwtService.digest_refresh_token(refresh_token)

    stored_token = RefreshToken.find_by(token_digest: token_digest)

    if stored_token.nil? || !stored_token.active?
      render json: {
        error: "Invalid or expired refresh token"
      }, status: :unauthorized
      return
    end

    access_token = JwtService.encode_access_token(stored_token.user_id)

    render json: {
      message: "Access token refreshed successfully",
      access_token: access_token
    }, status: :ok
  end

  def logout
    refresh_token = params[:refresh_token]

    if refresh_token.blank?
      render json: {
        error: "Refresh token is required"
      }, status: :unauthorized
      return
    end

    token_digest = JwtService.digest_refresh_token(refresh_token)

    stored_token = RefreshToken.find_by(token_digest: token_digest)

    if stored_token.nil?
      render json: {
        error: "Invalid refresh token"
      }, status: :unauthorized
      return
    end

    stored_token.revoke!

    render json: {
      message: "Logout successful"
    }, status: :ok
  end

  def forgot_password
    user = User.find_by(email: params[:email])

    if user
      reset_token = JwtService.generate_password_reset_token

      user.password_reset_tokens.create!(
        token_digest: JwtService.digest_password_reset_token(reset_token),
        expires_at: JwtService.password_reset_token_expiry
      )

      render json: {
        message: "Password reset token generated",
        reset_token: reset_token
      }, status: :ok
    else
      render json: {
        error: "User not found"
      }, status: :not_found
    end
  end

  def reset_password
    reset_token = params[:reset_token]
    password = params[:password]
    password_confirmation = params[:password_confirmation]

    if reset_token.blank?
      render json: {
        error: "Reset token is required"
      }, status: :unprocessable_content
      return
    end

    if password.blank?
      render json: {
        error: "Password is required"
      }, status: :unprocessable_content
      return
    end

    if password != password_confirmation
      render json: {
        error: "Password confirmation doesn't match Password"
      }, status: :unprocessable_content
      return
    end

    token_digest = JwtService.digest_password_reset_token(reset_token)

    stored_token = PasswordResetToken.find_by(token_digest: token_digest)

    if stored_token.nil? || !stored_token.active?
      render json: {
        error: "Invalid or expired reset token"
      }, status: :unauthorized
      return
    end

    user = stored_token.user

    user.password = password
    user.password_confirmation = password_confirmation

    unless user.save
      render json: {
        errors: user.errors.full_messages
      }, status: :unprocessable_content
      return
    end

    stored_token.mark_used!

    render json: {
      message: "Password reset successfully"
    }, status: :ok
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
