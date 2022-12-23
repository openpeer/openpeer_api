class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :list, null: false, index: true
      t.references :buyer, references: :users, null: false
      t.string :amount, null: false
      t.integer :status, enum: [:created, :cancelled, :dispute, :closed], default: 0
      t.string :tx_hash

      t.timestamps
    end
  end
end
