require 'rails_helper'

describe Api::V1::UsersController, type: :request do
  include_context 'authentication'

  describe '.show' do
    let(:user) { create(:user) }

    it 'returns the searched user' do
      get api_v1_user_path(user.address), headers: authentication_header

      expect(response).to be_successful
      json = ActiveModelSerializers::SerializableResource.new(user, serializer: UserSerializer).to_json
      expect(response.body).to eq(json)
    end
  end
end
