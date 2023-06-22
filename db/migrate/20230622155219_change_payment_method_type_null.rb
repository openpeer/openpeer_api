class ChangePaymentMethodTypeNull < ActiveRecord::Migration[7.0]
  def up
    change_column_null :payment_methods, :type, false
  end

  def down
    change_column_null :payment_methods, :type, true
  end
end
