class GenerateOrderPaymentMethods < ActiveRecord::Migration[7.0]
  def change
    Order.find_each do |order|
      list_pm = ListPaymentMethod.find(order.payment_method_id)
      order_pm = list_pm.dup
      order_pm.type = 'OrderPaymentMethod'
      order_pm.save!
      order.update(payment_method_id: order_pm.id)
    end
  end
end
