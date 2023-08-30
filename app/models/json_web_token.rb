class JsonWebToken
  SECRET_KEY = ENV['NEXTAUTH_SECRET']

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    public_key = OpenSSL::PKey::RSA.new(SECRET_KEY)
    decoded = JWT.decode(token, public_key, true, { algorithm: 'RS256' })[0]
    HashWithIndifferentAccess.new decoded
  end
end
