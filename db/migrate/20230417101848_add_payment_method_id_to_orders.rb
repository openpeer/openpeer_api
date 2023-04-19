class AddPaymentMethodIdToOrders < ActiveRecord::Migration[7.0]
  def change
    add_reference :orders, :payment_method, null: true, foreign_key: true
    execute <<-SQL
      UPDATE orders
      SET payment_method_id = lists.payment_method_id
      FROM lists
      WHERE lists.id = orders.list_id
    SQL
    change_column_null :orders, :payment_method_id, false
  end
end
