class BlockchainEventWorker
  include Sidekiq::Worker

  def perform(json)
    json = JSON.parse(json)
    puts json
    return unless ENV['POLYGON_STREAM_ID'] == json['streamId']

    chain_id = json['chainId']
    return unless chain_id

    chain_id = Integer(chain_id)
    log = json.fetch('logs')[0]
    data = log.fetch('data')
    event_inputs = ['uint256', 'address', 'address', 'address', 'uint256', 'uint8']
    id, token, seller, buyer, amount, status = Eth::Abi.decode(event_inputs, data)

    return unless (Eth::Address.new(token).valid? &&
                   Eth::Address.new(seller).valid? &&
                   Eth::Address.new(buyer).valid?) rescue false

    seller = User.where('lower(address) = ?', seller.downcase).first
    token = Token.where('lower(address) = ?', token.downcase).first

    return unless token
    # 10000000000000.to_f * 10 ** -18
    seller ||= User.create(address: Eth::Address.new(seller).checksummed)
    
    puts "id #{id}"
    puts "token #{token.address}"
    puts "seller #{seller.address}"
    puts "buyer #{buyer}"
    puts "amount #{amount}"
    puts "status #{status}"
    puts "chain_id #{chain_id}"
    
    decimal_amount = amount.to_f * 10 ** (token.decimals * -1)
    list = List.joins(:seller, :token)
               .where(chain_id: chain_id, status: status, token_id: token.id,
                      seller_id: seller.id).first
              #  .where('limit_min >= ? OR limit_min IS NULL', decimal_amount)
              #  .where('limit_max <= ? OR limit_max IS NULL', decimal_amount)

    return unless list

    buyer = User.where('lower(address) = ?', buyer.downcase).first
    buyer ||= User.create(address: Eth::Address.new(buyer).checksummed)

    tx_hash = log.fetch('transactionHash')
    Order.create(list_id: list.id, buyer: buyer.id, amount: amount, tx_hash: tx_hash)
  end
end
