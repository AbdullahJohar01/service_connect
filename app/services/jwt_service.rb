class JwtService
  def self.encode(user_id)
    payload = {
      user_id: user_id,
      exp: 24.hours.from_now.to_i
    }

    JWT.encode(
      payload,
      Rails.application.credentials.dig(:jwt, :secret),
      "HS256"
    )
  end

  def self.decode(token)
    decoded = JWT.decode(
      token,
      Rails.application.credentials.dig(:jwt, :secret),
      true,
      { algorithm: "HS256" }
    )

    decoded[0]
  rescue JWT::DecodeError
    nil
  end
end
