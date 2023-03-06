class ChangeTotalAvailableAmountType < ActiveRecord::Migration[7.0]
  def change
    change_column :lists, :total_available_amount, :decimal, using: 'total_available_amount::numeric'
  end
end
