class CreateDisputes < ActiveRecord::Migration[7.0]
  def change
    create_table :disputes do |t|
      t.references :order, null: false, foreign_key: true
      t.boolean :resolved, null: false, default: false

      t.timestamps
    end
  end
end
