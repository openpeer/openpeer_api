class CreateListsPaymentMethodsJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_table :lists_payment_methods, id: false do |t|
      t.references :list, null: false, foreign_key: true
      t.references :payment_method, null: false, foreign_key: true
    end

    add_index :lists_payment_methods, [:list_id, :payment_method_id], unique: true
  end
end
