class CreateFiatCurrencies < ActiveRecord::Migration[7.0]
  def change
    create_table :fiat_currencies do |t|
      t.string :code, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
