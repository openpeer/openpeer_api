class AddPositionToTokens < ActiveRecord::Migration[7.0]
  def change
    add_column :tokens, :position, :integer
  end
end
