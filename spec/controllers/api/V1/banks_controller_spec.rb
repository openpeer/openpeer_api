require 'rails_helper'

describe Api::V1::BanksController, type: :request do
  include_context 'authentication'

  describe '.index' do
    let!(:banks) { create_list(:bank, 10) }

    describe 'fiat_currency_id filter' do
      context 'with fiat_currency_id' do
        it 'returns banks from the fiat_currency_id' do
          currency = create(:fiat_currency)
          banks[9].update(fiat_currency: currency)
          get api_v1_banks_path, params: { currency_id: currency.id },
                                 headers: authentication_header
  
          expect(response).to be_successful
          json = ActiveModelSerializers::SerializableResource.new(banks, each_serializer: BankSerializer).to_json
          expect(response.body).to eq(json)
          expect(json_body[9]['fiat_currency']['id']).to eq(currency.id)
        end
      end
      
      context 'without fiat_currency_id' do
        it 'returns all the banks' do
          get api_v1_banks_path, headers: authentication_header
          
          expect(response).to be_successful
          json = ActiveModelSerializers::SerializableResource.new(banks, each_serializer: BankSerializer).to_json
          expect(response.body).to eq(json)
        end
      end
    end
  end
end
