class CreateTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :tokens do |t|
      t.string :address, null: false
      t.integer :decimals, null: false
      t.string :symbol, null: false
      t.string :name
      t.integer :chain_id, null: false
      t.string :coingecko_id, null: false

      t.timestamps
    end
    execute "CREATE UNIQUE INDEX index_tokens_on_lower_address_chain_id ON tokens USING btree (lower(address), chain_id);"
  end
end
