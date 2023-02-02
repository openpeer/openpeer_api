class CreateEscrows < ActiveRecord::Migration[7.0]
  def change
    create_table :escrows do |t|
      t.references :order, null: false, foreign_key: true
      t.string :tx
      t.string :address

      t.timestamps
    end
  end
end
