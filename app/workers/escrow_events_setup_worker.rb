class EscrowEventsSetupWorker
  include Sidekiq::Worker
  attr_accessor :contract
  POLYGON_CHAIN_ID = 137

  def perform(contract_id, chain_id)
    @contract = Contract.find(contract_id)
    id = @contract.id
    address = @contract.address
    chain_id = @contract.chain_id

    Moralis::SetupEscrow.new(address).execute
    return unless chain_id.to_i == POLYGON_CHAIN_ID

    Biconomy::SetupContract.new(id, address, chain_id).execute
    Biconomy::SetupMethods.new(id, address, chain_id).execute
  end
end
