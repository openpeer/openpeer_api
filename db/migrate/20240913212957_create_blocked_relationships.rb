class CreateBlockedRelationships < ActiveRecord::Migration[7.0]
  def change
    create_table :blocked_relationships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :blocked_user, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end

    add_index :blocked_relationships, [:user_id, :blocked_user_id], unique: true
  end
end