module Api
  class BaseController < ApplicationController
    include ActionController::HttpAuthentication::Basic::ControllerMethods
    include ActionController::HttpAuthentication::Token::ControllerMethods

    before_action :authenticate

    private

    def authenticate
      authenticate_or_request_with_http_token do |token, _options|
        ApiUser.find_by(token: token)
      end
    end

    def current_user
      @current_user ||= authenticate
    end
  end
end
