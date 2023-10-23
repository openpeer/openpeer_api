class AddEscrowTypeToLists < ActiveRecord::Migration[7.0]
  def change
    add_column :lists, :escrow_type, :integer, enum: [:manual, :instant], default: 0
  end
end
