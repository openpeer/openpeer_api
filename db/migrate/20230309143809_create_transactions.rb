class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.references :order, null: false, foreign_key: true
      t.string :tx_hash

      t.timestamps
    end
  end
end
