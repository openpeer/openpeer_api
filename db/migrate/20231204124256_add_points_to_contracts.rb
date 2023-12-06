class AddPointsToContracts < ActiveRecord::Migration[7.0]
  def change
    add_column :contracts, :points, :decimal
  end
end
