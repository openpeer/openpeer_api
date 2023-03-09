class UpdatePaymentMethods < ActiveRecord::Migration[7.0]
  def change
    add_column :payment_methods, :values, :json

    remove_column :payment_methods, :account_name, :string
    remove_column :payment_methods, :account_number, :string
    remove_column :payment_methods, :details, :text
  end
end
