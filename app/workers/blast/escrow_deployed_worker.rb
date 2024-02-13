module Blast
  class EscrowDeployedWorker
    include Sidekiq::Worker

    def perform(json)
      json = JSON.parse(json)

      webhook = OpenStruct.new(json)
      return unless webhook.isLive

      event = OpenStruct.new(webhook.event)
      seller = event.args['_seller']
      address = event.args['_deployment']
      return unless seller && address

      seller = User.find_or_create_by_address(seller)
      version = Setting['contract_version'] || '1'
      chain_id = webhook.transaction.fetch('chainId', Blast::CHAIN_ID)

      return if seller.contracts.find_by(address: address, chain_id: chain_id, version: version)

      contract = seller.contracts.create(address: address, chain_id: chain_id, version: version)

      Blast::EscrowEventsSetupWorker.new.perform(contract.id)
    end
  end
end
