require 'rails_helper'

xdescribe BlockchainEventWorker do
  subject { described_class.new }

  describe '.perform' do
    context 'with a wrong stream id' do
      let(:params) { {} }
      it 'does not create an order' do
        expect { subject.perform(params.to_json) }.to_not change { Order.count }
      end
    end

    context 'with a wrong stream id' do
      let(:params) { { chain_id: nil } }
      it 'does not create an order' do
        expect { subject.perform(params.to_json) }.to_not change { Order.count }
      end
    end

    context 'with valid data' do
      let(:list) { create(:list) }
      let(:buyer) { '5f5e3148532d1682866131a1971bb74a92d96376'.downcase } # without 0x
      let(:seller) { Eth::Util.remove_hex_prefix(list.seller.address).downcase }
      let(:token) { Eth::Util.remove_hex_prefix(list.token.address).downcase }
      let(:params) do
        { streamId: ENV['POLYGON_STREAM_ID'], chainId: "0x#{list.chain_id.to_s(16)}",
        logs: [{
          data: "0x0000000000000000000000000000000000000000000000000000000000000006000000000000000000000000#{token}000000000000000000000000#{seller}000000000000000000000000#{buyer}00000000000000000000000000000000000000000000000000000000009896800000000000000000000000000000000000000000000000000000000000000000" 
          }]
        }
      end
      
      it 'should create an order' do
        expect { subject.perform(params.to_json) }.to change { Order.count }.by(1)
      end
    end
  end
end
