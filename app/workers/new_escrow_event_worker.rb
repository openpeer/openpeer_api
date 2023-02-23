class NewEscrowEventWorker
  include Sidekiq::Worker

  MARK_AS_PAID  = '0xf86890b0'
  BUYER_CANCEL  = '0xe9d13b57'
  OPEN_DISPUTE  = '0x4fd6137c'
  RELEASE       = '0x86d1a69f'
  SELLER_CANCEL = '0xd55a17c0'

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
    user = User.where('lower(address) = ?', tx['fromAddress'].downcase).first

    return unless escrow && user
    order = escrow.order

    case tx['input']
    when MARK_AS_PAID
      order.update(status: :release)
      NotificationWorker.perform_async(NotificationWorker::BUYER_PAID, order.id)
    when BUYER_CANCEL, SELLER_CANCEL
      order.cancel(user)
    when OPEN_DISPUTE
      order.update(status: :dispute)
      NotificationWorker.perform_async(NotificationWorker::DISPUTE_OPENED, order.id)
    when RELEASE
      order.update(status: :closed)
      NotificationWorker.perform_async(NotificationWorker::SELLER_RELEASED, order.id)
    end

    ActionCable.server.broadcast("OrdersChannel_#{order.uuid}",
      ActiveModelSerializers::SerializableResource.new(order, include: '**').to_json)
  end
end
