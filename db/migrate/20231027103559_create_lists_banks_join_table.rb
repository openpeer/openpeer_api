class CreateListsBanksJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_table :lists_banks, id: false do |t|
      t.references :list, null: false, foreign_key: true
      t.references :bank, null: false, foreign_key: true
    end

    add_index :lists_banks, [:list_id, :bank_id], unique: true
  end
end
