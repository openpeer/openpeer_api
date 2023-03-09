class RemoveTxHashFromOrders < ActiveRecord::Migration[7.0]
  def change
    remove_column :orders, :tx_hash, :string
  end
end
