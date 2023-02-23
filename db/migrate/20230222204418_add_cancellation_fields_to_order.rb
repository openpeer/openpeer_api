class AddCancellationFieldsToOrder < ActiveRecord::Migration[7.0]
  def change
    add_reference :orders, :cancelled_by, null: true, foreign_key: { to_table: :users }
    add_column :orders, :cancelled_at, :datetime, null: true
  end
end
