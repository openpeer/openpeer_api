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
    event_inputs = ['bytes32', 'bool', 'address']
    trade_id, exists, address = Eth::Abi.decode(event_inputs, data)

    tx = json.fetch('txs', [])[0]
    return unless tx

    trade_id = Uuid.convert_string_bytes_32(trade_id) rescue nil
    return unless trade_id

    order = Order.includes(:list)
                 .find_by(trade_id: trade_id, status: :created,
                         lists: { chain_id: chain_id })
    return unless order

    return if order.escrow.present?

    Order.transaction do
      order.update(status: :escrowed)
      order.create_escrow(tx: log['transactionHash'], address: address)
    end

    EscrowEventsSetupWorker.perform_async(order.escrow.id)
    NotificationWorker.perform_async(NotificationWorker::SELLER_ESCROWED, order.id)
    order.broadcast

    return order.escrow
  end
end
