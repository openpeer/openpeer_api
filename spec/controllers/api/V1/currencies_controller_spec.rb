require 'rails_helper'

describe Api::V1::CurrenciesController, type: :request do
  include_context 'authentication'

  describe '.index' do
    let!(:currencies) { create_list(:fiat_currency, 10) }

    it 'returns all the currencies' do
      get api_v1_currencies_path, headers: authentication_header

      expect(response).to be_successful
      json = ActiveModelSerializers::SerializableResource.new(currencies, each_serializer: FiatCurrencySerializer).to_json
      expect(response.body).to eq(json)
    end
  end
end
