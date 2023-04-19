class AddBankIdToLists < ActiveRecord::Migration[7.0]
  def change
    add_reference :lists, :bank, foreign_key: true
  end
end
