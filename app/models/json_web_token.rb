class JsonWebToken
  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, ENV['DYNAMIC_PUBLIC_KEY'])
  end

  def self.decode(token)
    public_key = OpenSSL::PKey::RSA.new(ENV['DYNAMIC_PUBLIC_KEY']) # @TODO: change before deploy
    begin
      decoded = JWT.decode(token, public_key, true, { algorithm: 'RS256' })
    rescue JWT::DecodeError
      decoded = JWT.decode(token, ENV['TRON_AUTH_PRIVATE_KEY'], true, { algorithm: 'HS256' })
    end

    HashWithIndifferentAccess.new decoded[0]
  end
end
