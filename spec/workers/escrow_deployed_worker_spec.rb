require 'rails_helper'

describe EscrowDeployedWorker do
  subject { described_class.new }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('DEPLOYER_STREAM_ID').and_return('test')
  end

  describe '.perform' do
    let(:params) { { streamId: 'test', chainId: '0x89', logs: [{ data: '' }] }}
    let(:chain_id) { 137 }
    let(:token) { create(:token, address: '0x0000000000000000000000000000000000000000', decimals: 18) }
    let(:seller) { create(:seller, address: '0x630220d00Cf136270f553c8577aF18300F7b812c') }
    let(:buyer) { create(:buyer, address: '0xb98206a86e61bc59e9632d06679a5515ebf02e81') }
    let(:escrow_address) { '0xd82ad457ab4ccb2dbf29557762a5019bd16f4e75' }
    let(:uuid) { '0x170d42a8469659195611063eba7f000000000000000000000000000000000000' }
    let(:list) { create(:list, seller: seller, token: token, chain_id: chain_id) }
    let(:token_amount) { 0.000000000001 }
    let!(:order) do
      create(:order, uuid: uuid, buyer: buyer, list: list, token_amount: token_amount)
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
          .and_return(['id', true, escrow_address, seller.address, buyer.address, 'invalid', token_amount])
        expect { subject.perform(params.to_json) }.to_not change { Escrow.count }
      end
    end

    context 'with an invalid seller' do
      it 'does not create an escrow' do
        allow(Eth::Abi).to receive(:decode)
          .and_return(['id', true, escrow_address, 'invalid', buyer.address, token.address, token_amount])
        expect { subject.perform(params.to_json) }.to_not change { Escrow.count }
      end
    end

    context 'with an invalid buyer' do
      it 'does not create an escrow' do
        allow(Eth::Abi).to receive(:decode)
          .and_return(['id', true, escrow_address, seller.address, 'invalid', token.address, token_amount])
        expect { subject.perform(params.to_json) }.to_not change { Escrow.count }
      end
    end

    context 'with a inexistent token' do
      it 'does not create an escrow' do
        allow(Eth::Abi).to receive(:decode)
          .and_return(['id', true, escrow_address, seller.address, buyer.address,
            '0x0000000000000000000000000000000000000000', token_amount])
        expect { subject.perform(params.to_json) }.to_not change { Escrow.count }
      end
    end

    context 'with a token from other chain' do
      let(:token) { create(:token, address: '0x0000000000000000000000000000000000000000', chain_id: 1 )}
      it 'does not create an escrow' do
        allow(Eth::Abi).to receive(:decode)
          .and_return(['id', true, escrow_address, seller.address, buyer.address,
            '0x0000000000000000000000000000000000000000', token_amount])
        expect { subject.perform(params.to_json) }.to_not change { Escrow.count }
      end
    end

    context 'when the uuid cant be converted' do
      it 'does not create an escrow' do
        allow(Eth::Abi).to receive(:decode)
          .and_return([nil, true, escrow_address, seller.address, buyer.address, token.address, token_amount])
        expect { subject.perform(params.to_json) }.to_not change { Escrow.count }
      end
    end

    context 'when the order cannot be found' do
      context 'wrong uuid' do
        it 'does not create an escrow' do
          allow(Eth::Abi).to receive(:decode)
            .and_return([Uuid.generate, true, escrow_address, seller.address, buyer.address,
                         token.address, token_amount])
          expect { subject.perform(params.to_json) }.to_not change { Escrow.count }
        end
      end

      context 'wrong status' do
        let!(:order) do
          create(:order, uuid: uuid, buyer: buyer, list: list, token_amount: token_amount, status: :dispute)
        end

        it 'does not create an escrow' do
          allow(Eth::Abi).to receive(:decode)
            .and_return([uuid, true, escrow_address, seller.address, buyer.address,
                         token.address, token_amount])
          expect { subject.perform(params.to_json) }.to_not change { Escrow.count }
        end
      end

      context 'wrong buyer' do
        let(:another_buyer) { create(:buyer) }

        it 'does not create an escrow' do
          allow(Eth::Abi).to receive(:decode)
            .and_return([uuid, true, escrow_address, seller.address, another_buyer.address,
                         token.address, token_amount])
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
                          token.address, token_amount])
            expect { subject.perform(params.to_json) }.to_not change { Escrow.count }
          end
        end

        context 'wrong seller' do
          let(:another_seller) { create(:seller) }
          it 'does not create an escrow' do
            allow(Eth::Abi).to receive(:decode)
              .and_return([uuid, true, escrow_address, another_seller.address, buyer.address,
                          token.address, token_amount])
            expect { subject.perform(params.to_json) }.to_not change { Escrow.count }
          end
        end

        context 'wrong token' do
          let(:another_token) { create(:token) }
          it 'does not create an escrow' do
            allow(Eth::Abi).to receive(:decode)
              .and_return([uuid, true, escrow_address, seller.address, buyer.address,
                           another_token.address, token_amount])
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
        expect(escrow.tx).to eq('0x20225d64d63be6f645963b4967b3546bf06122f2cba821a0e31a8578a2c32abe')
      end

      it 'updates the order status' do
        expect { subject.perform(params) }.to change { order.reload.status }.from('created').to('escrowed')
      end

      it 'enqueues the setup worker' do
        expect(EscrowEventsSetupWorker).to receive(:perform_async)
        subject.perform(params)
      end
    end
  end
end
