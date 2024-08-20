class AddUniqueIdentifierToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :unique_identifier, :string
    add_index :users, :unique_identifier, unique: true
  end
end

