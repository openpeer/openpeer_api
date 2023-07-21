class AddDepositTimeLimitToLists < ActiveRecord::Migration[7.0]
  def change
    add_column :lists, :deposit_time_limit, :integer
  end
end
