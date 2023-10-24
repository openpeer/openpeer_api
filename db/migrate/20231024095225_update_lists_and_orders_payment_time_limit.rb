class UpdateListsAndOrdersPaymentTimeLimit < ActiveRecord::Migration[7.0]
  def change
    List.update_all(payment_time_limit: 1440)
    Order.update_all(payment_time_limit: 1440)
  end
end
