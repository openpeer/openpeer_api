# spec/controllers/api/v1/user_search_controller_spec.rb
require 'rails_helper'

RSpec.describe Api::V1::UserSearchController, type: :controller do
  describe 'GET #show' do
    let(:user) { create(:user, address: '0x1234567890abcdef') }

    context 'when user is found' do
      it 'returns the user' do
        get :show, params: { id: user.address }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data']['id']).to eq(user.id)
      end
    end

    context 'when user is not found' do
      it 'returns not found message' do
        get :show, params: { id: 'nonexistentaddress' }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data']['message']).to eq('User not found')
      end
    end

    context 'when address is invalid' do
      it 'returns an error message' do
        allow(User).to receive(:find_by).and_raise(Eth::Address::CheckSumError)
        get :show, params: { id: 'invalidaddress' }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data']['message']).to eq('User not found')
      end
    end
  end
end