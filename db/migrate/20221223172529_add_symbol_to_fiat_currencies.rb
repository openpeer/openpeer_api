class AddSymbolToFiatCurrencies < ActiveRecord::Migration[7.0]
  def change
    add_column :fiat_currencies, :symbol, :string
  end
end
