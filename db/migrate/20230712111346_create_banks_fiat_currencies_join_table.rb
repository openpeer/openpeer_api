class CreateBanksFiatCurrenciesJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_table :banks_fiat_currencies, id: false do |t|
      t.references :bank, null: false, foreign_key: true
      t.references :fiat_currency, null: false, foreign_key: true
    end

    add_index :banks_fiat_currencies, [:bank_id, :fiat_currency_id], unique: true
  end
end
