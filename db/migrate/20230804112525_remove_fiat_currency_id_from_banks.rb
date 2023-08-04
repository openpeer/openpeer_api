class RemoveFiatCurrencyIdFromBanks < ActiveRecord::Migration[7.0]
  def change
    remove_column :banks, :fiat_currency_id, :bigint
  end
end
