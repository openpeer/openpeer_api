class AddGaslessToTokens < ActiveRecord::Migration[7.0]
  def change
    add_column :tokens, :gasless, :boolean, default: false
  end
end
