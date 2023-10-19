class CreateSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :settings do |t|
      t.string :name, null: false
      t.text :value, null: false
      t.text :description

      t.timestamps
    end

    add_index :settings, :name, unique: true
  end
end
