class CreateUserDisputes < ActiveRecord::Migration[7.0]
  def change
    create_table :user_disputes do |t|
      t.references :dispute, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :comments

      t.timestamps
    end
  end
end
