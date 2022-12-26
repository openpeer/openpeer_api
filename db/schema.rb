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

ActiveRecord::Schema[7.0].define(version: 2022_12_23_190648) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
  end

  create_table "fiat_currencies", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "symbol"
    t.string "country_code"
  end

  create_table "lists", force: :cascade do |t|
    t.integer "chain_id", null: false
    t.bigint "seller_id", null: false
    t.bigint "token_id", null: false
    t.bigint "fiat_currency_id", null: false
    t.string "total_available_amount"
    t.decimal "limit_min"
    t.decimal "limit_max"
    t.integer "margin_type", default: 0, null: false
    t.decimal "margin", null: false
    t.text "terms"
    t.boolean "automatic_approval", default: true
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chain_id", "seller_id"], name: "index_lists_on_chain_id_and_seller_id"
    t.index ["fiat_currency_id"], name: "index_lists_on_fiat_currency_id"
    t.index ["seller_id"], name: "index_lists_on_seller_id"
    t.index ["token_id"], name: "index_lists_on_token_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "list_id", null: false
    t.bigint "buyer_id", null: false
    t.string "amount", null: false
    t.integer "status", default: 0
    t.string "tx_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["buyer_id"], name: "index_orders_on_buyer_id"
    t.index ["list_id"], name: "index_orders_on_list_id"
  end

  create_table "orders_payment_methods", id: false, force: :cascade do |t|
    t.bigint "payment_method_id", null: false
    t.bigint "order_id", null: false
    t.index ["order_id", "payment_method_id"], name: "index_orders_payment_methods_on_order_id_and_payment_method_id"
    t.index ["payment_method_id", "order_id"], name: "index_orders_payment_methods_on_payment_method_id_and_order_id"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "account_name"
    t.string "account_number"
    t.bigint "bank_id"
    t.text "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_id"], name: "index_payment_methods_on_bank_id"
    t.index ["user_id"], name: "index_payment_methods_on_user_id"
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
    t.index "lower((address)::text), chain_id", name: "index_tokens_on_lower_address_chain_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "address", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((address)::text)", name: "index_users_on_lower_address", unique: true
  end

end
