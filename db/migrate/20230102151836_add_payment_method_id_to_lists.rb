class AddPaymentMethodIdToLists < ActiveRecord::Migration[7.0]
  def change
    add_reference :lists, :payment_method
  end
end
