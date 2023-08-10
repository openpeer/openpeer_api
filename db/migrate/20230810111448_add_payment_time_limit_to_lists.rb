class AddPaymentTimeLimitToLists < ActiveRecord::Migration[7.0]
  def change
    add_column :lists, :payment_time_limit, :integer
  end
end
