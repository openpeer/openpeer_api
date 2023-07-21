class AddDepositTimeLimitToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :deposit_time_limit, :integer
  end
end
