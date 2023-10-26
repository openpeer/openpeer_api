class EscrowEventsSetupWorker
  include Sidekiq::Worker
  attr_accessor :contract

  def perform(contract_id, chain_id)
    @contract = Contract.find(contract_id)
    id = @contract.id
    address = @contract.address
    chain_id = @contract.chain_id
    version = @contract.version

    Moralis::SetupEscrow.new(address).execute

    Biconomy::SetupContract.new(id, address, chain_id, version).execute
    Biconomy::SetupMethods.new(id, address, chain_id, version).execute
  end
end
