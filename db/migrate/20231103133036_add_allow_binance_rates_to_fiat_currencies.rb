class AddAllowBinanceRatesToFiatCurrencies < ActiveRecord::Migration[7.0]
  def change
    add_column :fiat_currencies, :allow_binance_rates, :boolean, default: false
  end
end
