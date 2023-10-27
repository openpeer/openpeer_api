# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_10_27_103559) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "api_users", force: :cascade do |t|
    t.string "name"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "banks", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "account_info_schema"
    t.string "color"
  end

  create_table "banks_fiat_currencies", id: false, force: :cascade do |t|
    t.bigint "bank_id", null: false
    t.bigint "fiat_currency_id", null: false
    t.index ["bank_id", "fiat_currency_id"], name: "index_banks_fiat_currencies_on_bank_id_and_fiat_currency_id", unique: true
    t.index ["bank_id"], name: "index_banks_fiat_currencies_on_bank_id"
    t.index ["fiat_currency_id"], name: "index_banks_fiat_currencies_on_fiat_currency_id"
  end

  create_table "cancellation_reasons", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_cancellation_reasons_on_order_id"
  end

  create_table "contracts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "chain_id"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "version"
    t.index ["user_id", "chain_id", "address", "version"], name: "index_contracts_on_user_id_and_chain_id_and_address_and_version", unique: true
    t.index ["user_id", "chain_id", "address"], name: "index_contracts_on_user_id_and_chain_id_and_address", unique: true
    t.index ["user_id"], name: "index_contracts_on_user_id"
  end

  create_table "dispute_files", force: :cascade do |t|
    t.bigint "user_dispute_id", null: false
    t.string "filename"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_dispute_id"], name: "index_dispute_files_on_user_dispute_id"
  end

  create_table "disputes", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.boolean "resolved", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "winner_id"
    t.index ["order_id"], name: "index_disputes_on_order_id"
    t.index ["winner_id"], name: "index_disputes_on_winner_id"
  end

  create_table "escrows", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "tx"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_escrows_on_order_id"
  end

  create_table "fiat_currencies", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "symbol"
    t.string "country_code"
    t.integer "position"
  end

  create_table "lists", force: :cascade do |t|
    t.integer "chain_id", null: false
    t.bigint "seller_id", null: false
    t.bigint "token_id", null: false
    t.bigint "fiat_currency_id", null: false
    t.decimal "total_available_amount"
    t.decimal "limit_min"
    t.decimal "limit_max"
    t.integer "margin_type", default: 0, null: false
    t.decimal "margin", null: false
    t.text "terms"
    t.boolean "automatic_approval", default: true
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "payment_method_id"
    t.string "type"
    t.bigint "bank_id"
    t.integer "deposit_time_limit"
    t.integer "payment_time_limit"
    t.boolean "accept_only_verified", default: false
    t.integer "escrow_type", default: 0
    t.index ["bank_id"], name: "index_lists_on_bank_id"
    t.index ["chain_id", "seller_id"], name: "index_lists_on_chain_id_and_seller_id"
    t.index ["fiat_currency_id"], name: "index_lists_on_fiat_currency_id"
    t.index ["payment_method_id"], name: "index_lists_on_payment_method_id"
    t.index ["seller_id"], name: "index_lists_on_seller_id"
    t.index ["token_id"], name: "index_lists_on_token_id"
    t.index ["type"], name: "index_lists_on_type"
  end

  create_table "lists_banks", id: false, force: :cascade do |t|
    t.bigint "list_id", null: false
    t.bigint "bank_id", null: false
    t.index ["bank_id"], name: "index_lists_banks_on_bank_id"
    t.index ["list_id", "bank_id"], name: "index_lists_banks_on_list_id_and_bank_id", unique: true
    t.index ["list_id"], name: "index_lists_banks_on_list_id"
  end

  create_table "lists_payment_methods", id: false, force: :cascade do |t|
    t.bigint "list_id", null: false
    t.bigint "payment_method_id", null: false
    t.index ["list_id", "payment_method_id"], name: "index_lists_payment_methods_on_list_id_and_payment_method_id", unique: true
    t.index ["list_id"], name: "index_lists_payment_methods_on_list_id"
    t.index ["payment_method_id"], name: "index_lists_payment_methods_on_payment_method_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "list_id", null: false
    t.bigint "buyer_id", null: false
    t.decimal "fiat_amount", null: false
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "token_amount"
    t.decimal "price"
    t.string "uuid"
    t.bigint "cancelled_by_id"
    t.datetime "cancelled_at"
    t.string "trade_id"
    t.bigint "seller_id", null: false
    t.bigint "payment_method_id", null: false
    t.integer "deposit_time_limit"
    t.integer "payment_time_limit"
    t.integer "chain_id", null: false
    t.index ["buyer_id"], name: "index_orders_on_buyer_id"
    t.index ["cancelled_by_id"], name: "index_orders_on_cancelled_by_id"
    t.index ["list_id"], name: "index_orders_on_list_id"
    t.index ["payment_method_id"], name: "index_orders_on_payment_method_id"
    t.index ["seller_id"], name: "index_orders_on_seller_id"
  end

  create_table "orders_payment_methods", id: false, force: :cascade do |t|
    t.bigint "payment_method_id", null: false
    t.bigint "order_id", null: false
    t.index ["order_id", "payment_method_id"], name: "index_orders_payment_methods_on_order_id_and_payment_method_id"
    t.index ["payment_method_id", "order_id"], name: "index_orders_payment_methods_on_payment_method_id_and_order_id"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "bank_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "values"
    t.string "type", null: false
    t.index ["bank_id"], name: "index_payment_methods_on_bank_id"
    t.index ["user_id"], name: "index_payment_methods_on_user_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "name", null: false
    t.text "value", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_settings_on_name", unique: true
  end

  create_table "tokens", force: :cascade do |t|
    t.string "address", null: false
    t.integer "decimals", null: false
    t.string "symbol", null: false
    t.string "name"
    t.integer "chain_id", null: false
    t.string "coingecko_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "coinmarketcap_id"
    t.boolean "gasless", default: false
    t.integer "position"
    t.decimal "minimum_amount"
    t.index "lower((address)::text), chain_id", name: "index_tokens_on_lower_address_chain_id", unique: true
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "tx_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_transactions_on_order_id"
  end

  create_table "user_disputes", force: :cascade do |t|
    t.bigint "dispute_id", null: false
    t.bigint "user_id", null: false
    t.text "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dispute_id"], name: "index_user_disputes_on_dispute_id"
    t.index ["user_id"], name: "index_user_disputes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "address", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "name"
    t.string "twitter"
    t.string "image"
    t.boolean "verified", default: false
    t.boolean "merchant", default: false
    t.index "lower((address)::text)", name: "index_users_on_lower_address", unique: true
    t.index ["merchant"], name: "index_users_on_merchant"
    t.index ["name"], name: "index_users_on_name", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "banks_fiat_currencies", "banks"
  add_foreign_key "banks_fiat_currencies", "fiat_currencies"
  add_foreign_key "cancellation_reasons", "orders"
  add_foreign_key "contracts", "users"
  add_foreign_key "dispute_files", "user_disputes"
  add_foreign_key "disputes", "orders"
  add_foreign_key "disputes", "users", column: "winner_id"
  add_foreign_key "escrows", "orders"
  add_foreign_key "lists", "banks"
  add_foreign_key "lists_banks", "banks"
  add_foreign_key "lists_banks", "lists"
  add_foreign_key "lists_payment_methods", "lists"
  add_foreign_key "lists_payment_methods", "payment_methods"
  add_foreign_key "orders", "payment_methods"
  add_foreign_key "orders", "users", column: "cancelled_by_id"
  add_foreign_key "orders", "users", column: "seller_id"
  add_foreign_key "transactions", "orders"
  add_foreign_key "user_disputes", "disputes"
  add_foreign_key "user_disputes", "users"
end
