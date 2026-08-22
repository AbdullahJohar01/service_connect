class JwtService
  ACCESS_TOKEN_EXPIRY = 15.minutes
  REFRESH_TOKEN_EXPIRY = 30.days
  PASSWORD_RESET_TOKEN_EXPIRY = 30.minutes

  def self.encode(user_id)
    encode_access_token(user_id)
  end

  def self.encode_access_token(user_id)
    payload = {
      user_id: user_id,
      token_type: "access",
      exp: ACCESS_TOKEN_EXPIRY.from_now.to_i
    }

    JWT.encode(
      payload,
      jwt_secret,
      "HS256"
    )
  end

  def self.decode(token)
    decode_access_token(token)
  end

  def self.decode_access_token(token)
    decoded = JWT.decode(
      token,
      jwt_secret,
      true,
      { algorithm: "HS256" }
    )

    payload = decoded[0]

    return nil unless payload["token_type"] == "access"

    payload
  rescue JWT::DecodeError
    nil
  end

  def self.generate_refresh_token
    SecureRandom.urlsafe_base64(64)
  end

  def self.digest_refresh_token(token)
    Digest::SHA256.hexdigest(token)
  end

  def self.refresh_token_expiry
    REFRESH_TOKEN_EXPIRY.from_now
  end

  def self.generate_password_reset_token
    SecureRandom.urlsafe_base64(64)
  end

  def self.digest_password_reset_token(token)
    Digest::SHA256.hexdigest(token)
  end

  def self.password_reset_token_expiry
    PASSWORD_RESET_TOKEN_EXPIRY.from_now
  end

  def self.jwt_secret
    Rails.application.credentials.dig(:jwt, :secret)
  end

  private_class_method :jwt_secret
end
