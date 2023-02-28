class CreateDisputes < ActiveRecord::Migration[7.0]
  def change
    create_table :disputes do |t|
      t.references :order, null: false, foreign_key: true
      t.text :seller_comment
      t.text :buyer_comment
      t.boolean :resolved, null: false, default: false
      t.references :winner, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
