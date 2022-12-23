require 'rails_helper'

describe Api::BaseController, type: :controller do
  include_context 'authentication'

  controller do
    def index
      render json: 'Hello World'
    end
  end

  context 'without the authorization header' do
    it 'returns an error' do
      get :index
      expect(response).to_not be_successful
      expect(response.body).to include('HTTP Token: Access denied')
    end
  end

  context 'with the authorization header' do
    it 'is successful' do
      request.headers["Authorization"] = "Token #{api_user.token}"
      get :index
      expect(response).to be_successful
      expect(response.body).to include('Hello World')
    end
  end
end
