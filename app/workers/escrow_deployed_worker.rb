class EscrowDeployedWorker
  include Sidekiq::Worker

  def perform(json)
    json = JSON.parse(json)
    return unless ENV['DEPLOYER_STREAM_ID'] == json['streamId']

    chain_id = json['chainId']
    return unless chain_id

    chain_id = Integer(chain_id)
    log = json.fetch('logs', [])[0]
    return unless log

    data = log.fetch('data')
    event_inputs = ['address', 'address']
    seller, address = Eth::Abi.decode(event_inputs, data)

    return unless seller && address

    seller = User.find_or_create_by_address(seller)
    contract = seller.contracts.create(address: address, chain_id: chain_id)

    EscrowEventsSetupWorker.new.perform(contract.id)
  end
end
