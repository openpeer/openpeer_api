class CreateTrustedRelationships < ActiveRecord::Migration[7.0]
  def change
    create_table :trusted_relationships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :trusted_user, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end

    add_index :trusted_relationships, [:user_id, :trusted_user_id], unique: true
  end
end