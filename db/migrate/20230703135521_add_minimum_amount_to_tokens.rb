class AddMinimumAmountToTokens < ActiveRecord::Migration[7.0]
  def change
    add_column :tokens, :minimum_amount, :decimal
  end
end
