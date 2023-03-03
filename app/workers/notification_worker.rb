require "knock"

class NotificationWorker
  include Sidekiq::Worker

  NEW_ORDER = 'new-order'
  SELLER_ESCROWED = 'seller-escrowed'
  BUYER_PAID = 'buyer-paid'
  SELLER_RELEASED = 'seller-released'
  ORDER_CANCELLED = 'order-cancelled'
  DISPUTE_OPENED = 'dispute-opened'

  def perform(type, order_id)
    order = Order.includes(:list, :buyer, :cancelled_by).find(order_id)
    seller = order.list.seller
    buyer = order.buyer

    actor = case type
            when NEW_ORDER, BUYER_PAID
              seller
            when SELLER_ESCROWED, SELLER_RELEASED, DISPUTE_OPENED
              buyer
            when ORDER_CANCELLED
              order.cancelled_by.id == seller.id ? buyer : seller
            end

    recipients = [{ id: actor.address, name: actor.name, email: actor.email }]

    if order.dispute?
      recipients = [{ id: seller.address, name: seller.name, email: seller.email },
                    { id: buyer.address, name: buyer.name, email: buyer.email }]
    end

    Knock::Workflows.trigger(
      key: type,
      actor: { id: actor.address, name: actor.name, email: actor.email },
      recipients: recipients,
      data: {
        username: actor.name || small_wallet_address(actor.address),
        seller: seller.name || small_wallet_address(seller.address),
        buyer: buyer.name || small_wallet_address(buyer.address),
        cancelled_by: order.cancelled_by,
        token_amount: order.token_amount.to_s,
        fiat_amount: order.fiat_amount.to_s,
        token: order.list.token.symbol,
        fiat: order.list.fiat_currency.code,
        price: order.price.to_s,
        url: "#{ENV['FRONTEND_URL']}/orders/#{order.uuid}",
        uuid: small_wallet_address(order.uuid, 6)
      }
    )
  end

  private

  def small_wallet_address(address, length = 4)
    "#{address[0, length]}..#{address[-length, length]}"
  end
end
