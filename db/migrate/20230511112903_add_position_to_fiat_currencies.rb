class AddPositionToFiatCurrencies < ActiveRecord::Migration[7.0]
  def change
    add_column :fiat_currencies, :position, :integer
  end
end
