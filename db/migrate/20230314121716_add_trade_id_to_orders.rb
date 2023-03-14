class AddTradeIdToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :trade_id, :string
  end
end
