require 'rails_helper'

describe BlockchainEventWorker do
  subject { described_class.new }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('POLYGON_STREAM_ID').and_return('test')
  end

  describe '.perform' do
    let(:params) { { streamId: 'test', chainId: '0x89', logs: [{ data: '' }] }}
    let(:chain_id) { 137 }
    let(:token) { create(:token, address: '0xc2132D05D31c914a87C6611C10748AEb04B58e8F' )}
    let(:seller) { create(:seller, address: '0x630220d00Cf136270f553c8577aF18300F7b812c') }
    let(:buyer) { create(:buyer, address: '0xFE6b7A4494B308f8c0025DCc635ac22630ec7330') }
    let(:escrow_address) { '0xf7dbe61a0b758cff72195657e448339ac788d8cf' }
    let(:uuid) { '0x33ca11fabf2821fad8b46c6fcec7000000000000000000000000000000000000' }
    let(:list) { create(:list, seller: seller, token: token, chain_id: chain_id) }
    let!(:order) do
      create(:order, uuid: uuid, buyer: buyer, list: list, token_amount: 1000000)
    end


    context 'with a wrong stream id' do
      let(:params) { {} }
      it 'does not create an escrow' do
        expect { subject.perform(params.to_json) }.to_not change { Escrow.count }
      end
    end

    context 'with a wrong chain_id id' do
      let(:params) { { streamId: 'test', chainId: nil } }
      it 'does not create an escrow' do
        expect { subject.perform(params.to_json) }.to_not change { Escrow.count }
      end
    end

    context 'with an invalid token' do
      it 'does not create an escrow' do
        allow(Eth::Abi).to receive(:decode)
          .and_return(['id', true, escrow_address, seller.address, buyer.address, 'invalid', 1000000])
        expect { subject.perform(params.to_json) }.to_not change { Escrow.count }
      end
    end

    context 'with an invalid seller' do
      it 'does not create an escrow' do
        allow(Eth::Abi).to receive(:decode)
          .and_return(['id', true, escrow_address, 'invalid', buyer.address, token.address, 1000000])
        expect { subject.perform(params.to_json) }.to_not change { Escrow.count }
      end
    end

    context 'with an invalid buyer' do
      it 'does not create an escrow' do
        allow(Eth::Abi).to receive(:decode)
          .and_return(['id', true, escrow_address, seller.address, 'invalid', token.address, 1000000])
        expect { subject.perform(params.to_json) }.to_not change { Escrow.count }
      end
    end

    context 'with a inexistent token' do
      it 'does not create an escrow' do
        allow(Eth::Abi).to receive(:decode)
          .and_return(['id', true, escrow_address, seller.address, buyer.address,
            '0x0000000000000000000000000000000000000000', 1000000])
        expect { subject.perform(params.to_json) }.to_not change { Escrow.count }
      end
    end

    context 'with a token from other chain' do
      let(:token) { create(:token, address: '0x0000000000000000000000000000000000000000', chain_id: 1 )}
      it 'does not create an escrow' do
        allow(Eth::Abi).to receive(:decode)
          .and_return(['id', true, escrow_address, seller.address, buyer.address,
            '0x0000000000000000000000000000000000000000', 1000000])
        expect { subject.perform(params.to_json) }.to_not change { Escrow.count }
      end
    end

    context 'when the uuid cant be converted' do
      it 'does not create an escrow' do
        allow(Eth::Abi).to receive(:decode)
          .and_return([nil, true, escrow_address, seller.address, buyer.address, token.address, 1000000])
        expect { subject.perform(params.to_json) }.to_not change { Escrow.count }
      end
    end

    context 'when the order cannot be found' do
      context 'wrong uuid' do
        it 'does not create an escrow' do
          allow(Eth::Abi).to receive(:decode)
            .and_return([Uuid.generate, true, escrow_address, seller.address, buyer.address,
                         token.address, 1000000])
          expect { subject.perform(params.to_json) }.to_not change { Escrow.count }
        end
      end

      context 'wrong status' do
        let!(:order) do
          create(:order, uuid: uuid, buyer: buyer, list: list, token_amount: 1000000, status: :dispute)
        end

        it 'does not create an escrow' do
          allow(Eth::Abi).to receive(:decode)
            .and_return([uuid, true, escrow_address, seller.address, buyer.address,
                         token.address, 1000000])
          expect { subject.perform(params.to_json) }.to_not change { Escrow.count }
        end
      end

      context 'wrong buyer' do
        let(:another_buyer) { create(:buyer) }

        it 'does not create an escrow' do
          allow(Eth::Abi).to receive(:decode)
            .and_return([uuid, true, escrow_address, seller.address, another_buyer.address,
                         token.address, 1000000])
          expect { subject.perform(params.to_json) }.to_not change { Escrow.count }
        end
      end

      context 'wrong token amount' do
        it 'does not create an escrow' do
          allow(Eth::Abi).to receive(:decode)
            .and_return([uuid, true, escrow_address, seller.address, buyer.address,
                         token.address, 0])
          expect { subject.perform(params.to_json) }.to_not change { Escrow.count }
        end
      end

      context 'with a bad list' do
        context 'wrong chain id' do
          let(:chain_id) { 1 }
          it 'does not create an escrow' do
            allow(Eth::Abi).to receive(:decode)
              .and_return([uuid, true, escrow_address, seller.address, buyer.address,
                          token.address, 1000000])
            expect { subject.perform(params.to_json) }.to_not change { Escrow.count }
          end
        end

        context 'wrong seller' do
          let(:another_seller) { create(:seller) }
          it 'does not create an escrow' do
            allow(Eth::Abi).to receive(:decode)
              .and_return([uuid, true, escrow_address, another_seller.address, buyer.address,
                          token.address, 1000000])
            expect { subject.perform(params.to_json) }.to_not change { Escrow.count }
          end
        end

        context 'wrong token' do
          let(:another_token) { create(:token) }
          it 'does not create an escrow' do
            allow(Eth::Abi).to receive(:decode)
              .and_return([uuid, true, escrow_address, seller.address, buyer.address,
                           another_token.address, 1000000])
            expect { subject.perform(params.to_json) }.to_not change { Escrow.count }
          end
        end
      end
    end

    context 'with valid data' do
      let(:params) { file_fixture('event_webhook.json').read }
      
      it 'creates an escrow' do
        expect(order.escrow).to be_nil
        escrow = subject.perform(params)
        expect(escrow.address).to eq(escrow_address)
        expect(escrow.tx).to eq('0x4b05f122f43774f878842f0e04789d1023b2ca994c82334a0244a7aa419c6311')
      end

      it 'updates the order status' do
        expect { subject.perform(params) }.to change { order.reload.status }.from('created').to('escrowed')
      end
    end
  end
end
