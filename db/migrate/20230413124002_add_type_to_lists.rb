class AddTypeToLists < ActiveRecord::Migration[7.0]
  def change
    add_column :lists, :type, :string
    add_index :lists, :type
  end
end
