class AddImportedOrdersCountToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :imported_orders_count, :integer, default: 0
  end
end
