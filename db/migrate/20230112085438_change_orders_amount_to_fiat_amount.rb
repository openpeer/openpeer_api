class ChangeOrdersAmountToFiatAmount < ActiveRecord::Migration[7.0]
  def change
    rename_column :orders, :amount, :fiat_amount
  end
end
