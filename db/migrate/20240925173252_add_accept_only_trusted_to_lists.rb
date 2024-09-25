# db/migrate/20231103133021_add_accept_only_trusted_to_lists.rb
class AddAcceptOnlyTrustedToLists < ActiveRecord::Migration[7.0]
  def change
    add_column :lists, :accept_only_trusted, :boolean, default: false
  end
end