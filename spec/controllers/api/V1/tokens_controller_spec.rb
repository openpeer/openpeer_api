require 'rails_helper'

describe Api::V1::TokensController, type: :request do
  include_context 'authentication'

  describe '.index' do
    let!(:tokens) { create_list(:token, 10) }

    describe 'chain_id filter' do
      context 'with chain_id' do
        it 'returns tokens from the chain_id' do
          tokens[0].update(chain_id: 100_000_000)
          get api_v1_tokens_path, params: { chain_id: 100_000_000 },
                                  headers: authentication_header
  
          expect(response).to be_successful
          expect(response.body).to eq([tokens[0]].to_json)
        end
      end

      context 'without chain_id' do
        it 'returns all the tokens' do
          get api_v1_tokens_path, headers: authentication_header
  
          expect(response).to be_successful
          expect(response.body).to eq(tokens.to_json)
        end
      end
    end
  end
end
