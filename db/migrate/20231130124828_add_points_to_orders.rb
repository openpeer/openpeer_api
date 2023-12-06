class AddPointsToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :points, :decimal
  end
end
