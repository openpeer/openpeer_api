class AddLockedValueToContracts < ActiveRecord::Migration[7.0]
  def change
    add_column :contracts, :locked_value, :decimal
  end
end
