class AddChainIdToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :chain_id, :integer
    execute <<-SQL
      UPDATE orders
        SET chain_id = lists.chain_id
      FROM lists
        WHERE lists.id = orders.list_id
    SQL
    change_column_null :orders, :chain_id, false
  end
end
