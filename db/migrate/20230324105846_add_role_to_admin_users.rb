class AddRoleToAdminUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :admin_users, :role, :integer, enum: [:admin, :user], default: 0
  end
end
