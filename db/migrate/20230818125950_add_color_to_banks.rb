class AddColorToBanks < ActiveRecord::Migration[7.0]
  def change
    add_column :banks, :color, :string
  end
end
