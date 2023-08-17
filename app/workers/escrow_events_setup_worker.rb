class EscrowEventsSetupWorker
  include Sidekiq::Worker
  attr_accessor :contract
  BICONOMY_ENABLED_CHAIN_IDS = [137, 80001]

  def perform(contract_id, chain_id)
    @contract = Contract.find(contract_id)
    id = @contract.id
    address = @contract.address
    chain_id = @contract.chain_id

    Moralis::SetupEscrow.new(address).execute
    return unless BICONOMY_ENABLED_CHAIN_IDS.include?(chain_id.to_i)

    Biconomy::SetupContract.new(id, address, chain_id).execute
    Biconomy::SetupMethods.new(id, address, chain_id).execute
  end
end
