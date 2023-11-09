class AddAvailableTimesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :timezone, :string
    add_column :users, :available_from, :integer
    add_column :users, :available_to, :integer
    add_column :users, :weekend_offline, :boolean, default: false
  end
end
