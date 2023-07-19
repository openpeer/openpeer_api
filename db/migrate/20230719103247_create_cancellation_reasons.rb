class CreateCancellationReasons < ActiveRecord::Migration[7.0]
  def change
    create_table :cancellation_reasons do |t|
      t.references :order, null: false, foreign_key: true
      t.text :reason

      t.timestamps
    end
  end
end
