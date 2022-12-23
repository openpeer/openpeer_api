class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :address, null: false

      t.timestamps
    end
    execute "CREATE UNIQUE INDEX index_users_on_lower_address ON users USING btree (lower(address));"
  end
end
