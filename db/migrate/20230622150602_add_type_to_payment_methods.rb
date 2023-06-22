class AddTypeToPaymentMethods < ActiveRecord::Migration[7.0]
  def change
    add_column :payment_methods, :type, :string
    execute("UPDATE payment_methods SET type = 'ListPaymentMethod'")
  end
end
