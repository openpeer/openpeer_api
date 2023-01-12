class ChangeDataTypeForOrdersFiatAmount < ActiveRecord::Migration[7.0]
  def self.up
    change_table :orders do |t|
      t.change :fiat_amount, :decimal, using: "fiat_amount::numeric"
    end
  end
  def self.down
    change_table :orders do |t|
      t.change :fiat_amount, :string
    end
  end
end
