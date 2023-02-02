class BlockchainEventWorker
  include Sidekiq::Worker

  def perform(json)
    json = JSON.parse(json)
    return unless ENV['POLYGON_STREAM_ID'] == json['streamId']

    chain_id = json['chainId']
    return unless chain_id

    chain_id = Integer(chain_id)
    log = json.fetch('logs')[0]
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
                 .find_by(uuid: uuid, status: :created, buyer_id: buyer.id, token_amount: amount,
                         lists: { chain_id: chain_id, seller_id: seller.id,
                                  token_id: token.id })
    return unless order

    Order.transaction do
      order.update(status: :escrowed)
      order.create_escrow(tx: log['transactionHash'], address: address)
    end
  end

  private

  def find_or_create_user(address)
    User.where('lower(address) = ?', address.downcase).first ||
      User.create(address: Eth::Address.new(address).checksummed)
  end
end
