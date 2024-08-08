class AddTelegramAndWhatsappToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :telegram_user_id, :bigint
    add_column :users, :telegram_username, :string
    add_column :users, :whatsapp_country_code, :string
    add_column :users, :whatsapp_number, :string

    add_index :users, :telegram_user_id, unique: true
  end
end
