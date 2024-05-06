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

ActiveRecord::Schema[7.1].define(version: 2024_05_05_175656) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "inventory_items", force: :cascade do |t|
    t.bigint "seller_id"
    t.bigint "produce_id"
    t.decimal "unit_price", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "quantity", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["produce_id"], name: "index_inventory_items_on_produce_id"
    t.index ["seller_id", "produce_id"], name: "index_inventory_items_on_seller_id_and_produce_id", unique: true
    t.index ["seller_id"], name: "index_inventory_items_on_seller_id"
  end

  create_table "order_details", force: :cascade do |t|
    t.decimal "unit_price", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "quantity", default: 0, null: false
    t.bigint "order_id"
    t.bigint "inventory_item_id"
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_item_id"], name: "index_order_details_on_inventory_item_id"
    t.index ["order_id", "inventory_item_id"], name: "index_order_details_on_order_id_and_inventory_item_id", unique: true
    t.index ["order_id"], name: "index_order_details_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "buyer_id"
    t.decimal "total_price", precision: 10, scale: 2, null: false
    t.integer "status", default: 0, null: false
    t.datetime "cancelled_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["buyer_id"], name: "index_orders_on_buyer_id"
  end

  create_table "produces", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_produces_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "inventory_items", "produces"
  add_foreign_key "inventory_items", "users", column: "seller_id"
  add_foreign_key "order_details", "inventory_items"
  add_foreign_key "order_details", "orders"
  add_foreign_key "orders", "users", column: "buyer_id"

  create_view "buyer_produce_orders", sql_definition: <<-SQL
      SELECT o.buyer_id,
      ii.produce_id,
      date_trunc('day'::text, o.created_at) AS order_date,
      lead(date_trunc('day'::text, o.created_at)) OVER (PARTITION BY o.buyer_id, ii.produce_id ORDER BY (date_trunc('day'::text, o.created_at))) AS next_order_date
     FROM ((orders o
       JOIN order_details od ON ((o.id = od.order_id)))
       JOIN inventory_items ii ON ((od.inventory_item_id = ii.id)))
    WHERE ((o.cancelled_at IS NULL) AND (ii.quantity > 0));
  SQL
end
