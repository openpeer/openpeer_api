class AddSellerIdToOrders < ActiveRecord::Migration[7.0]
  def change
    add_reference :orders, :seller, references: :users, null: true, foreign_key: { to_table: :users }
    execute <<-SQL
      UPDATE orders
      SET seller_id = lists.seller_id
      FROM lists
      WHERE lists.id = orders.list_id
    SQL
    change_column_null :orders, :seller_id, false
  end
end
