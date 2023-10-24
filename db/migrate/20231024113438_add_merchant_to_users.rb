class AddMerchantToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :merchant, :boolean, default: false
    add_index :users, :merchant
  end
end
