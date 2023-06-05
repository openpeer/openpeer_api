class CreateContracts < ActiveRecord::Migration[7.0]
  def change
    create_table :contracts do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :chain_id
      t.string :address

      t.timestamps
    end
    add_index :contracts, [:user_id, :chain_id, :address], unique: true
  end
end
