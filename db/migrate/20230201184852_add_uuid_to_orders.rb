class AddUuidToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :uuid, :string
  end
end
