class AddReferencesToDisputes < ActiveRecord::Migration[7.0]
  def change
    add_reference :disputes, :winner, foreign_key: { to_table: :users }, optional: true
  end
end
