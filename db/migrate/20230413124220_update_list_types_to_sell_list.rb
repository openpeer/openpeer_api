class UpdateListTypesToSellList < ActiveRecord::Migration[7.0]
  def up
    List.update_all(type: 'SellList')
  end

  def down
    List.update_all(type: nil)
  end
end
