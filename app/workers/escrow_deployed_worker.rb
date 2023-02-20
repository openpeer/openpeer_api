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
    event_inputs = ['bytes32', 'bool', 'address', 'address', 'address', 'address', 'uint256']
    order_id, exists, address, seller, buyer, token, amount = Eth::Abi.decode(event_inputs, data)
    return unless ((Eth::Address.new(token).valid? &&
                    Eth::Address.new(seller).valid? &&
                    Eth::Address.new(buyer).valid?) rescue false)

    token = Token.where('lower(address) = ?', token.downcase)
                 .where(chain_id: chain_id).first
    return unless token

    uuid = Uuid.convert_string_bytes_32(order_id) rescue nil
    return unless uuid

    seller = find_or_create_user(seller)
    buyer = find_or_create_user(buyer)
    order = Order.includes(:list)
                 .find_by(uuid: uuid, status: :created, buyer_id: buyer.id,
                         token_amount: amount.to_f / (10**token.decimals).to_f,
                         lists: { chain_id: chain_id, seller_id: seller.id,
                                  token_id: token.id })
    return unless order

    return if order.escrow.present?

    Order.transaction do
      order.update(status: :escrowed)
      order.create_escrow(tx: log['transactionHash'], address: address)
    end

    EscrowEventsSetupWorker.perform_async(order.escrow.id)
    NotificationWorker.perform_async(NotificationWorker::SELLER_ESCROWED, order.id)
    ActionCable.server.broadcast("OrdersChannel_#{order.uuid}",
      ActiveModelSerializers::SerializableResource.new(order, include: '**').to_json)
    return order.escrow
  end

  private

  def find_or_create_user(address)
    User.find_or_create_by_address(address)
  end
end
