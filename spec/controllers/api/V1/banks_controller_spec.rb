require 'rails_helper'

describe Api::V1::BanksController, type: :request do
  include_context 'authentication'

  describe '.index' do
    let!(:banks) { create_list(:bank, 10) }

    describe 'fiat_currency_id filter' do
      context 'with fiat_currency_id' do
        it 'returns banks from the fiat_currency_id' do
          banks[9].update(fiat_currency_id: 100_000_000)
          get api_v1_banks_path, params: { currency_id: 100_000_000 },
                                 headers: authentication_header
  
          expect(response).to be_successful
          expect(response.body).to eq(banks.to_json)
          expect(json_body[9]['fiat_currency_id']).to eq(100_000_000)
        end
      end

      context 'without fiat_currency_id' do
        it 'returns all the banks' do
          get api_v1_banks_path, headers: authentication_header
  
          expect(response).to be_successful
          expect(response.body).to eq(banks.to_json)
        end
      end
    end
  end
end
