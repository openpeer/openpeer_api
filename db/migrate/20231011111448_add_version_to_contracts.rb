class AddVersionToContracts < ActiveRecord::Migration[7.0]
  def change
    add_column :contracts, :version, :string
    add_index :contracts, [:user_id, :chain_id, :address, :version], unique: true
    Contract.update_all(version: '1')
  end
end
