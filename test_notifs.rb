seller = User.find_by!(telegram_user_id: 468259635)
buyer = User.find_by!(telegram_user_id: 468259635)

token = Token.first

fiat_currency = FiatCurrency.first

payment_method = ListPaymentMethod.create!(
  user: seller,
  bank: Bank.first,
  values: { "upi_id" => "test123@upi" }
)

list = List.create!(
  seller: seller, 
  token: token, 
  fiat_currency: fiat_currency, 
  chain_id: token.chain_id,
  payment_time_limit: 60,
  banks: [Bank.first],
  margin: 0.01,
  margin_type: :fixed,
  payment_method: payment_method
  )

# Create the order
order = Order.create!(
  list: list,
  buyer: buyer,
  seller: seller,
  fiat_amount: 100,
  token_amount: 1,
  status: :created,
  chain_id: list.chain_id,
  payment_method: OrderPaymentMethod.create!(
    user: buyer,
    bank: Bank.first,
    values: { "upi_id" => "buyer123@upi" }
  )
)

# Test all notification types
notification_types = [
  NotificationWorker::NEW_ORDER,
  NotificationWorker::SELLER_ESCROWED,
  NotificationWorker::BUYER_PAID,
  NotificationWorker::SELLER_RELEASED,
  NotificationWorker::ORDER_CANCELLED,
  NotificationWorker::DISPUTE_OPENED,
  NotificationWorker::DISPUTE_RESOLVED
]

notification_types.each do |type|
  puts "Testing notification: #{type}"
  NotificationWorker.new.perform(type, order.id)
  sleep 2 # Wait a bit between notifications
end

puts "All notifications tested!"

// TODO: have the script clean up after itself.