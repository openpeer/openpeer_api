module Blast
  class EscrowEventsSetupWorker
    include Sidekiq::Worker
    attr_accessor :contract

    def perform(contract_id)
      @contract = Contract.find(contract_id)
      id = @contract.id
      address = @contract.address
      chain_id = @contract.chain_id

      Blast::ESCROW_EVENTS.each do |event|
        Blast::SetupEscrowEvent.perform_async(address, chain_id, event)
      end
    end
  end
end
