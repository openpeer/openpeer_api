require 'rails_helper'

describe NewEscrowEventWorker do
  subject { described_class.new }
  let(:params) { { streamId: 'test', chainId: '0x89', logs: [{ data: '' }] }}
  let(:chain_id) { 137 }
  let(:buyer) { create(:buyer, address: '0xb98206a86e61bc59e9632d06679a5515ebf02e81') }
  let(:order) { create(:order, buyer: buyer) }
  let!(:escrow) do
    create(:escrow, address: '0xf4ffad38bef7ab593843fd401cbfaafa4b2f9edf', order: order)
  end

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('ESCROW_EVENTS_STREAM_ID').and_return('test')
  end

  describe '.perform' do
    context 'with a wrong stream id' do
      let(:params) { {} }
      it 'does not update the order status' do
        expect { subject.perform(params.to_json) }.to_not change { order.status }
      end
    end

    context 'with a wrong chain_id id' do
      let(:params) { { streamId: 'test', chainId: nil } }
      it 'does not update the order status' do
        expect { subject.perform(params.to_json) }.to_not change { order.status}
      end
    end

    context 'without logs' do
      let(:params) { { streamId: 'test', chainId: '0x89', logs: [] }}
      it 'does not update the order status' do
        expect { subject.perform(params.to_json) }.to_not change { order.status}
      end
    end

    context 'without txs' do
      let(:params) { { streamId: 'test', chainId: '0x89', logs: [{ data: '' }], txs: [] }}
      it 'does not update the order status' do
        expect { subject.perform(params.to_json) }.to_not change { order.status}
      end
    end

    context 'mark as paid' do
      context 'with valid data' do
        let(:params) { file_fixture('seller_cancel_disabled.json').read }

        it 'updates the order status to release' do
          expect { subject.perform(params) }.to change { order.reload.status }.from('created').to('release')
        end
      end
    end
  end
end
