module Api
  class JwtController < BaseController
    before_action :authenticate

    private

    def authenticate
      authenticate_or_request_with_http_token do |jwt_token, _options|
        token = JsonWebToken.decode(jwt_token)
        address = token['sub']
        exp = token['exp']
        return if Time.now.to_i > exp

        User.where('lower(address) = ?', address.downcase).first ||
          User.create(address: Eth::Address.new(address).checksummed)
      end
    end

    def current_user
      @current_user ||= authenticate
    end
  end
end
