class NewEscrowEventWorker
  include Sidekiq::Worker

  MARK_AS_PAID     = '0xf86890b0'
  BUYER_CANCEL     = '0xe9d13b57'
  OPEN_DISPUTE     = '0x4fd6137c'
  RELEASE          = '0x86d1a69f'
  SELLER_CANCEL    = '0xd55a17c0'
  DISPUTE_RESOLVED = '0xd8461182'

  def perform(json)
    json = JSON.parse(json)
    return unless ENV['ESCROW_EVENTS_STREAM_ID'] == json['streamId']

    chain_id = json['chainId']
    return unless chain_id

    chain_id = Integer(chain_id)
    log = json.fetch('logs', [])[0]
    tx = json.fetch('txs', [])[0]

    return unless log && tx

    escrow = Escrow.includes(:order).where('lower(address) = ?', log['address'].downcase).first
    relayed = tx['toAddress'].downcase != escrow.address.downcase
    return unless escrow

    order = escrow.order
    tx_hash = log['transactionHash']

    return if order.transactions.where(tx_hash: tx_hash).any?

    if relayed
      input = topic_hashes[log['topic0']]
      user = find_user_based_by_input(input, order)
    else
      user = User.where('lower(address) = ?', tx['fromAddress'].downcase).first
      input = tx['input']
    end

    return unless input && user

    dispute = order.dispute
    buyer_action = user.id == order.buyer_id

    case input
    when MARK_AS_PAID
      order.update(status: :release)
      NotificationWorker.perform_async(NotificationWorker::BUYER_PAID, order.id)
    when BUYER_CANCEL, SELLER_CANCEL
      Order.transaction do
        order.cancel!(user)
        dispute.update(resolved: true, winner: buyer_action ? order.list.seller : order.buyer) if dispute
      end
    when OPEN_DISPUTE
      order.update(status: :dispute)
      NotificationWorker.perform_async(NotificationWorker::DISPUTE_OPENED, order.id)
    when RELEASE
      Order.transaction do
        order.update(status: :closed)
        dispute.update(resolved: true, winner: order.buyer) if dispute
      end
      NotificationWorker.perform_async(NotificationWorker::SELLER_RELEASED, order.id)
    end

    if input.starts_with?(DISPUTE_RESOLVED)
      encoded_address = input.sub(DISPUTE_RESOLVED, '')
      address = Eth::Abi.decode(["address"], "0x#{encoded_address}")[0]
      winner = User.where('lower(address) = ?', address.downcase).first

      Order.transaction do
        order.update(status: :closed)
        dispute ||= order.build_dispute
        dispute.resolved = true
        dispute.winner = winner
        dispute.save
      end
      NotificationWorker.perform_async(NotificationWorker::DISPUTE_RESOLVED, order.id)
    end

    order.transactions.create(tx_hash: tx_hash)
    order.broadcast
  end

  private

  def abi
    @abi ||= JSON.parse(File.read(Rails.root.join('config', 'abis', 'OpenPeerEscrow.json')))
  end

  def events
    @events ||= abi.filter { |i| i['type'] == 'event' }
  end

  def topic_hashes
    @topic_hashes ||= begin
      mark_as_paid = events.find { |i| i['name'] == 'SellerCancelDisabled' }
      buyer_cancel = events.find { |i| i['name'] == 'CancelledByBuyer' }
      open_dispute = events.find { |i| i['name'] == 'DisputeOpened' }
      release = events.find { |i| i['name'] == 'Released' }
      seller_cancel = events.find { |i| i['name'] == 'CancelledBySeller' }
      dispute_resolved = events.find { |i| i['name'] == 'DisputeResolved' }

      hashes = {}
      hashes[Eth::Abi::Event.compute_topic(mark_as_paid)] = MARK_AS_PAID
      hashes[Eth::Abi::Event.compute_topic(buyer_cancel)] = BUYER_CANCEL
      hashes[Eth::Abi::Event.compute_topic(open_dispute)] = OPEN_DISPUTE
      hashes[Eth::Abi::Event.compute_topic(release)] = RELEASE
      hashes[Eth::Abi::Event.compute_topic(seller_cancel)] = SELLER_CANCEL
      hashes[Eth::Abi::Event.compute_topic(dispute_resolved)] = DISPUTE_RESOLVED
      hashes
    end
  end

  def find_user_based_by_input(input, order)
    return unless input

    case input
    when MARK_AS_PAID, BUYER_CANCEL
      order.buyer
    when SELLER_CANCEL, RELEASE
      order.list.seller
    end
  end
end
