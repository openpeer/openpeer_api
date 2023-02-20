require "knock"

class NotificationWorker
  include Sidekiq::Worker

  NEW_ORDER = 'new-order'
  SELLER_ESCROWED = 'seller-escrowed'
  BUYER_PAID = 'buyer-paid'
  SELLER_RELEASED = 'seller-released'

  def perform(type, order_id)
    order = Order.includes(:list, :buyer).find(order_id)
    seller = order.list.seller
    buyer = order.buyer

    recipient = case type
            when NEW_ORDER, BUYER_PAID
              seller
            when SELLER_ESCROWED, SELLER_RELEASED
              buyer
            end

    Knock::Workflows.trigger(
      key: type,
      actor: { id: recipient.address, name: recipient.name, email: recipient.email },
      recipients: [{ id: recipient.address, name: recipient.name, email: recipient.email }],
      data: {
        username: recipient.name || small_wallet_address(recipient.address),
        seller: seller.name || small_wallet_address(seller.address),
        buyer: buyer.name || small_wallet_address(buyer.address),
        token_amount: order.token_amount.to_s,
        fiat_amount: order.fiat_amount.to_s,
        token: order.list.token.symbol,
        fiat: order.list.fiat_currency.code,
        price: order.price.to_s,
        url: "#{ENV['FRONTEND_URL']}/orders/#{order.uuid}"
      }
    )
  end

  private

  def small_wallet_address(address, length = 4)
    "#{address[0, length]}..#{address[-length, length]}"
  end
end
