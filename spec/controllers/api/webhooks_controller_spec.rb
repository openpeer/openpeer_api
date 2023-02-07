require 'rails_helper'

describe Api::WebhooksController, type: :request do
  describe '.index' do
    it 'returns 200' do
      get api_webhooks_path
      expect(response).to be_successful
    end
  end

  describe '.create' do
    it 'enqueues EscrowDeployedWorker' do
      params = { chainId: '0x1' }
      post api_webhooks_path, params: params
      expect(EscrowDeployedWorker).to have_enqueued_sidekiq_job(params.to_json)
      expect(response).to be_successful
    end
  end
end
