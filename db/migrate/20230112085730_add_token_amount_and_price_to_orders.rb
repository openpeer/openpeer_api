class AddTokenAmountAndPriceToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :token_amount, :decimal
    add_column :orders, :price, :decimal
  end
end
