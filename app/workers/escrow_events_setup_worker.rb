class EscrowEventsSetupWorker
  include Sidekiq::Worker
  attr_accessor :contract

  def perform(contract_id)
    @contract = Contract.find(contract_id)
    id = @contract.id
    address = @contract.address
    chain_id = @contract.chain_id

    Moralis::SetupEscrow.new(address).execute
    Biconomy::SetupContract.new(id, address, chain_id).execute
    Biconomy::SetupMethods.new(id, address, chain_id).execute
  end
end
