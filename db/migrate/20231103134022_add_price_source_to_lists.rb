class AddPriceSourceToLists < ActiveRecord::Migration[7.0]
  def change
    add_column :lists, :price_source, :integer,
      enum: [:coingecko, :binance_median, :binance_min, :binance_max], default: 0
  end
end
