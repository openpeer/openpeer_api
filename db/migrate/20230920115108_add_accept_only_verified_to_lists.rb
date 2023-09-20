class AddAcceptOnlyVerifiedToLists < ActiveRecord::Migration[7.0]
  def change
    add_column :lists, :accept_only_verified, :boolean, default: false
  end
end
