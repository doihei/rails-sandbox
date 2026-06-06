class JwtService
  ALGORITHM = "HS256"
  EXPIRY = 24.hours

  def self.encode(payload)
    payload = payload.merge(exp: EXPIRY.from_now.to_i)
    JWT.encode(payload, secret_key, ALGORITHM)
  end

  def self.decode(token)
    decoded_token = JWT.decode(token, secret_key, true, { algorithm: ALGORITHM })
    HashWithIndifferentAccess.new(decoded_token.first)
  rescue JWT::ExpiredSignature
    raise JWT::ExpiredSignature, I18n.t("errors.token_expired")
  rescue JWT::DecodeError
    raise JWT::DecodeError, I18n.t("errors.token_invalid")
  end

  private

  def self.secret_key
    Rails.application.credentials.secret_key_base
  end
end
