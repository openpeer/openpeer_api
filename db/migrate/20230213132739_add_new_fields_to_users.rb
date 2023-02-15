class AddNewFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :name, :string
    add_column :users, :twitter, :string
    add_column :users, :image, :string
    add_column :users, :verified, :boolean, default: false

    add_index :users, :name, unique: true
  end
end
