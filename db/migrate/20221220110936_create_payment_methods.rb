class CreatePaymentMethods < ActiveRecord::Migration[7.0]
  def change
    create_table :payment_methods do |t|
      t.references :user, references: :users, null: false
      t.string :account_name
      t.string :account_number
      t.references :bank, references: :banks
      t.text :details

      t.timestamps
    end
  end
end
