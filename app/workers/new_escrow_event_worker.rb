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

    case tx['input']
    when MARK_AS_PAID
      escrow.order.update(status: :release)
    when BUYER_CANCEL, SELLER_CANCEL
      escrow.order.update(status: :cancelled)
    when OPEN_DISPUTE
      escrow.order.update(status: :dispute)
    when RELEASE
      escrow.order.update(status: :closed)
    end
  end
end