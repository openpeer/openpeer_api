class CreateListsBanksJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_table :lists_banks, id: false do |t|
      t.references :list, null: false, foreign_key: true
      t.references :bank, null: false, foreign_key: true
    end

    add_index :lists_banks, [:list_id, :bank_id], unique: true

    List.transaction do
      List.find_each do |list|
        return unless list.bank.present?

        list.banks << list.bank
        list.save
      end
    end
  end
end
