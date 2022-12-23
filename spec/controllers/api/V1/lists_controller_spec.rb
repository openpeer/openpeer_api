require 'rails_helper'

describe Api::V1::ListsController, type: :request do
  include_context 'authentication'

  describe '.index' do
    let!(:lists) { create_list(:list, 10, status: List.statuses[:created]) }

    describe 'status filter' do
      context 'with status' do
        it 'returns lists with the desired status' do
          lists[0].update(status: List.statuses[:active])
          get api_v1_lists_path, params: { status: 'active' },
                                  headers: authentication_header
  
          expect(response).to be_successful
          expect(response.body).to eq([lists[0]].to_json)
        end
      end
      
      context 'without status' do
        it 'returns all the lists' do
          get api_v1_lists_path, headers: authentication_header
  
          expect(response).to be_successful
          expect(response.body).to eq(lists.to_json)
        end
      end
    end

    describe 'seller filter' do
      context 'with seller' do
        it 'returns lists from the seller' do
          get api_v1_lists_path, params: { seller: lists[0].seller.address },
                                  headers: authentication_header
  
          expect(response).to be_successful
          expect(response.body).to eq([lists[0]].to_json)
        end
      end
    end

    describe 'chain_id filter' do
      context 'with chain_id' do
        it 'returns lists from the chain_id' do
          lists[0].update(chain_id: 100_000_000)
          get api_v1_lists_path, params: { chain_id: 100_000_000 },
                                  headers: authentication_header
  
          expect(response).to be_successful
          expect(response.body).to eq([lists[0]].to_json)
        end
      end
    end
  end
end
