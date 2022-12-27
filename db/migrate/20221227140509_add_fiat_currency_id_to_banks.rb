class AddFiatCurrencyIdToBanks < ActiveRecord::Migration[7.0]
  def change
    add_reference :banks, :fiat_currency
  end
end
