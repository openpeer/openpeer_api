require "knock"

class NotificationWorker
  include Sidekiq::Worker

  NEW_ORDER = 'new-order'
  SELLER_ESCROWED = 'seller-escrowed'
  BUYER_PAID = 'buyer-paid'
  SELLER_RELEASED = 'seller-released'
  ORDER_CANCELLED = 'order-cancelled'
  DISPUTE_OPENED = 'dispute-opened'
  DISPUTE_RESOLVED = 'dispute-resolved'

  def perform(type, order_id)
    order = Order.includes(:list, :buyer, :cancelled_by).find(order_id)
    seller = order.seller
    buyer = order.buyer
    winner = order.dispute&.winner

    actor = case type
            when NEW_ORDER, BUYER_PAID
              seller
            when SELLER_ESCROWED, SELLER_RELEASED, DISPUTE_OPENED
              buyer
            when ORDER_CANCELLED
              order.cancelled_by.id == seller.id ? buyer : seller
            when DISPUTE_RESOLVED
              winner
            end

    actor_profile = { id: actor&.address, name: actor&.name, email: actor&.email }
    recipients = [actor_profile]

    if order.dispute? || type == DISPUTE_RESOLVED
      recipients = [{ id: seller.address, name: seller.name, email: seller.email },
                    { id: buyer.address, name: buyer.name, email: buyer.email }]
    end

    cancelled_by = order.cancelled_by
    Knock::Workflows.trigger(
      key: type,
      actor: actor_profile,
      recipients: recipients,
      data: {
        username: actor&.name.presence || small_wallet_address(actor&.address || ''),
        seller: seller.name.presence || small_wallet_address(seller.address),
        buyer: buyer.name.presence || small_wallet_address(buyer.address),
        cancelled_by: cancelled_by ? (cancelled_by.name.presence || small_wallet_address(cancelled_by.address)) : nil,
        token_amount: order.token_amount.to_s,
        fiat_amount: order.fiat_amount.to_s,
        token: order.list.token.symbol,
        fiat: order.list.fiat_currency.code,
        price: order.price.to_s,
        url: "#{ENV['FRONTEND_URL']}/orders/#{order.uuid}",
        uuid: small_wallet_address(order.uuid, 6),
        winner: winner ? (winner.name.presence || small_wallet_address(winner.address)) : nil,
      }
    )
  end

  private

  def small_wallet_address(address, length = 4)
    "#{address[0, length]}..#{address[-length, length]}"
  end
end
