module Api
  class BaseController < ApplicationController
    include ActionController::HttpAuthentication::Basic::ControllerMethods
    include ActionController::HttpAuthentication::Token::ControllerMethods

    before_action :authenticate_api_token

    private

    def authenticate_api_token
      @current_api_user = ApiUser.find_by(token: request.headers['X-Access-Token'])
      return render json: { error: 'API user not found' }, status: :unauthorized unless @current_api_user

      @current_api_user
    end

    def current_api_user
      @current_api_user ||= authenticate_api_token
    end
  end
end
