class CreateLists < ActiveRecord::Migration[7.0]
  def change
    create_table :lists do |t|
      t.integer :chain_id, null: false
      t.references :seller, references: :users, null: false
      t.references :token, references: :tokens, null: false
      t.references :fiat_currency, references: :fiat_currencies, null: false
      t.string :total_available_amount
      t.decimal :limit_min
      t.decimal :limit_max
      t.integer :margin_type, enum: [:fixed, :percentage], null: false, default: 0
      t.decimal :margin, null: false
      t.text :terms
      t.boolean :automatic_approval, default: true
      t.integer :status, enum: [:created, :active, :closed], default: 0

      t.timestamps
    end
    add_index :lists, [:chain_id, :seller_id]
  end
end
