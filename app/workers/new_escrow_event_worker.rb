class NewEscrowEventWorker
  include Sidekiq::Worker

  MARK_AS_PAID     = '0xf86890b0'
  BUYER_CANCEL     = '0xe9d13b57'
  OPEN_DISPUTE     = '0x4fd6137c'
  RELEASE          = '0x86d1a69f'
  SELLER_CANCEL    = '0xd55a17c0'
  DISPUTE_RESOLVED = '0xd8461182'
  CREATE_ERC20     = '0x9851a25e'
  CREATE_NATIVE    = '0x9f5e5628'

  def perform(json)
    json = JSON.parse(json)
    return unless ENV['ESCROW_EVENTS_STREAM_ID'] == json['streamId']

    chain_id = json['chainId']
    return unless chain_id

    chain_id = Integer(chain_id)
    log = json.fetch('logs', [])[0]
    tx = json.fetch('txs', [])[0]

    return unless log && tx

    trade_id = log.fetch('topic1')
    return unless trade_id

    order = Order.includes(:list)
                 .find_by(trade_id: trade_id, chain_id: chain_id)
    return unless order

    contract = Contract.where(chain_id: chain_id)
                       .where('lower(address) = ?', log['address'].downcase).first ||
               Contract.create(chain_id: chain_id, address: Eth::Address.new(log['address']).checksummed,
                               user_id: order.seller_id, version: Setting['contract_version'])
    return unless contract

    relayed = tx['toAddress'].downcase != contract.address.downcase
    input = topic_hashes(contract.version)[log['topic0']]
    if relayed
      user = find_user_based_by_input(input, order)
    else
      user = User.where('lower(address) = ?', tx['fromAddress'].downcase).first
    end

    return unless input && user

    tx_hash = log['transactionHash']

    return if order.transactions.where(tx_hash: tx_hash).any?
    dispute = order.dispute
    buyer_action = user.id == order.buyer_id

    case input
    when CREATE_ERC20, CREATE_NATIVE
      Order.transaction do
        order.update(status: :escrowed)
        order.create_escrow(tx: log['transactionHash'], address: contract.address)
      end

      NotificationWorker.perform_async(NotificationWorker::SELLER_ESCROWED, order.id)
    when MARK_AS_PAID
      order.update(status: :release)
      NotificationWorker.perform_async(NotificationWorker::BUYER_PAID, order.id)
    when BUYER_CANCEL, SELLER_CANCEL
      Order.transaction do
        order.cancel!(user)
        dispute.update(resolved: true, winner: buyer_action ? order.seller : order.buyer) if dispute
      end
    when OPEN_DISPUTE
      order.update(status: :dispute)
      NotificationWorker.perform_async(NotificationWorker::DISPUTE_OPENED, order.id)
    when DISPUTE_RESOLVED
      address = Eth::Abi.decode(['address'], log.fetch('topic2'))[0]
      winner = User.where('lower(address) = ?', address.downcase).first

      Order.transaction do
        order.update(status: :closed)
        dispute ||= order.build_dispute
        dispute.resolved = true
        dispute.winner = winner
        dispute.save
      end
      NotificationWorker.perform_async(NotificationWorker::DISPUTE_RESOLVED, order.id)
    when RELEASE
      Order.transaction do
        order.update(status: :closed)
        dispute.update(resolved: true, winner: order.buyer) if dispute
      end
      NotificationWorker.perform_async(NotificationWorker::SELLER_RELEASED, order.id)
    end

    order.transactions.create(tx_hash: tx_hash)
    order.broadcast
  end

  private

  def abi(version)
    @abi ||= JSON.parse(File.read(Rails.root.join('config', 'abis', version, 'OpenPeerEscrow.json')))
  end

  def events(version)
    @events ||= abi(version).filter { |i| i['type'] == 'event' }
  end

  def topic_hashes(version)
    @topic_hashes ||= begin
      mark_as_paid = events(version).find { |i| i['name'] == 'SellerCancelDisabled' }
      buyer_cancel = events(version).find { |i| i['name'] == 'CancelledByBuyer' }
      open_dispute = events(version).find { |i| i['name'] == 'DisputeOpened' }
      release = events(version).find { |i| i['name'] == 'Released' }
      seller_cancel = events(version).find { |i| i['name'] == 'CancelledBySeller' }
      dispute_resolved = events(version).find { |i| i['name'] == 'DisputeResolved' }
      escrow_created = events(version).find { |i| i['name'] == 'EscrowCreated' }

      hashes = {}
      hashes[Eth::Abi::Event.compute_topic(mark_as_paid)] = MARK_AS_PAID
      hashes[Eth::Abi::Event.compute_topic(buyer_cancel)] = BUYER_CANCEL
      hashes[Eth::Abi::Event.compute_topic(open_dispute)] = OPEN_DISPUTE
      hashes[Eth::Abi::Event.compute_topic(release)] = RELEASE
      hashes[Eth::Abi::Event.compute_topic(seller_cancel)] = SELLER_CANCEL
      hashes[Eth::Abi::Event.compute_topic(dispute_resolved)] = DISPUTE_RESOLVED
      hashes[Eth::Abi::Event.compute_topic(escrow_created)] = CREATE_ERC20
      hashes
    end
  end

  def find_user_based_by_input(input, order)
    return unless input

    case input
    when MARK_AS_PAID, BUYER_CANCEL
      order.buyer
    when SELLER_CANCEL, RELEASE, CREATE_ERC20, CREATE_NATIVE
      order.seller
    end
  end
end
