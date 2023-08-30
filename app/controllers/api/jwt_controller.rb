module Api
  class JwtController < BaseController
    before_action :authenticate

    private

    def authenticate
      authenticate_or_request_with_http_token do |jwt_token, _options|
        token = JsonWebToken.decode(jwt_token)
        address = token['verified_credentials'].first['address']
        exp = token['exp']
        return if Time.now.to_i > exp

        User.find_or_create_by_address(address)
      end
    end

    def current_user
      @current_user ||= authenticate
    end
  end
end
