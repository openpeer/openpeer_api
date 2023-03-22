class EscrowEventsSetupWorker
  include Sidekiq::Worker
  attr_accessor :escrow

  def perform(escrow_id)
    @escrow = Escrow.find(escrow_id)
    id = @escrow.id
    address = @escrow.address
    chain_id = @escrow.order.list.chain_id

    Moralis::SetupEscrow.new(address).execute
    Biconomy::SetupContract.new(id, address, chain_id).execute
    Biconomy::SetupMethods.new(id, address, chain_id).execute
  end
end
