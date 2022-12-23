class CreatePaymentMethodOrders < ActiveRecord::Migration[7.0]
  def change
    create_join_table :payment_methods, :orders do |t|
      t.index [:payment_method_id, :order_id]
      t.index [:order_id, :payment_method_id]
    end
  end
end
