# app/controllers/api/base_controller.rb

module Api
  class BaseController < ActionController::API
    include ActionController::HttpAuthentication::Basic::ControllerMethods
    include ActionController::HttpAuthentication::Token::ControllerMethods
    include ActiveStorage::SetCurrent

    before_action :authenticate_api_token

    before_action do
      if Rails.env.development?
        ActiveStorage::Current.url_options = { protocol: request.protocol, host: request.host, port: request.port }
      end
    end

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
