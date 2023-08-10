class AddPaymentTimeLimitToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :payment_time_limit, :integer
  end
end
