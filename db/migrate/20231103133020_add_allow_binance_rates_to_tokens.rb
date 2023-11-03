class AddAllowBinanceRatesToTokens < ActiveRecord::Migration[7.0]
  def change
    add_column :tokens, :allow_binance_rates, :boolean, default: false
  end
end
