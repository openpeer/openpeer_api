class AddAccountInfoSchemaToBanks < ActiveRecord::Migration[7.0]
  def change
    add_column :banks, :account_info_schema, :json
  end
end
