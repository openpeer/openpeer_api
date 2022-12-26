class AddCountryCodeToFiatCurrencies < ActiveRecord::Migration[7.0]
  def change
    add_column :fiat_currencies, :country_code, :string
  end
end
