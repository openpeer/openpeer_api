require "knock"
require 'telegram/bot'

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

    return if type === NEW_ORDER && (order.list.instant? || order.list.buy_list?)

    actor = case type
            when NEW_ORDER, BUYER_PAID
              seller
            when SELLER_ESCROWED, SELLER_RELEASED, DISPUTE_OPENED
              buyer
            when ORDER_CANCELLED
              order.cancelled_by&.id == seller.id ? buyer : seller
            when DISPUTE_RESOLVED
              winner
            end

    if actor.nil? || actor.address.nil?
      Rails.logger.error("Actor or actor address is nil for order #{order.id}")
      return
    end

    actor_profile = { id: actor&.address, name: actor&.name, email: actor&.email, telegram_user_id: actor&.telegram_user_id }
    recipients = [actor_profile]

    if order.dispute? || type == DISPUTE_RESOLVED
      recipients = [{ id: seller.address, name: seller.name, email: seller.email, telegram_user_id: seller.telegram_user_id  },
                    { id: buyer.address, name: buyer.name, email: buyer.email, telegram_user_id: buyer.telegram_user_id }]
    end

    cancelled_by = order.cancelled_by

    data = {
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
        payment_method: order.payment_method&.bank.name
      }

    Knock::Workflows.trigger(
      key: type,
      actor: actor_profile,
      recipients: recipients,
      data: data
    )

    send_telegram_notification(type, actor, recipients, data)
  end

  def send_telegram_notification(type, actor, recipients, data)
    bot = Telegram::Bot::Client.new(ENV['TELEGRAM_BOT_TOKEN'])
    
    recipients.each do |recipient|
      next unless recipient[:telegram_user_id]
  
      message = format_telegram_message(type, actor, data)
      begin
        response = bot.api.send_message(chat_id: recipient[:telegram_user_id], text: message)
        if response['ok']
          Rails.logger.info("Telegram notification sent successfully to user #{recipient[:telegram_user_id]} for order #{data[:uuid]}")
        else
          Rails.logger.warn("Failed to send Telegram notification to user #{recipient[:telegram_user_id]} for order #{data[:uuid]}: #{response['description']}")
        end
      rescue Telegram::Bot::Exceptions::ResponseError => e
        Rails.logger.error("Error sending Telegram notification to user #{recipient[:telegram_user_id]} for order #{data[:uuid]}: #{e.message}")
      end
    end
  end

  private

  def small_wallet_address(address, length = 4)
    "#{address[0, length]}..#{address[-length, length]}"
  end

  def format_telegram_message(type, actor, data)
    case type
    when NEW_ORDER
      "New order received from #{data[:buyer]} for #{data[:token_amount]} #{data[:token]} (#{data[:fiat_amount]} #{data[:fiat]})"
    when SELLER_ESCROWED
      "Seller #{data[:seller]} has escrowed #{data[:token_amount]} #{data[:token]} for your order"
    when BUYER_PAID
      "Buyer #{data[:buyer]} has marked the payment as sent for #{data[:fiat_amount]} #{data[:fiat]}"
    when SELLER_RELEASED
      "Seller #{data[:seller]} has released #{data[:token_amount]} #{data[:token]} for your order"
    when ORDER_CANCELLED
      "Order #{data[:uuid]} has been cancelled by #{data[:cancelled_by]}"
    when DISPUTE_OPENED
      "A dispute has been opened for order #{data[:uuid]}"
    when DISPUTE_RESOLVED
      "The dispute for order #{data[:uuid]} has been resolved. Winner: #{data[:winner]}"
    else
      "Order #{data[:uuid]} status update: #{type}"
    end
  end

  def self.test_notification(user_id)
    user = User.find(user_id)
    data = {
      username: user.name || small_wallet_address(user.address),
      uuid: 'TEST123',
      token_amount: '100',
      token: 'TEST',
      fiat_amount: '1000',
      fiat: 'USD'
    }
    
    new.send_telegram_notification('test', user, [user], data)
  end
  
end
