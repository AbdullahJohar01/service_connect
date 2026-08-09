class Api::V1::AuthController < Api::V1::BaseController
  def test
    render json: {
      message: "Authentication API is working"
    }
  end
end