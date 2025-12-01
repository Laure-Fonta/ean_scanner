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

ActiveRecord::Schema[7.1].define(version: 2025_11_28_135706) do
  create_table "inventory_scans", force: :cascade do |t|
    t.integer "inventory_session_id", null: false
    t.string "ean"
    t.boolean "found"
    t.integer "supplier_id"
    t.integer "supplier_item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_session_id"], name: "index_inventory_scans_on_inventory_session_id"
    t.index ["supplier_id"], name: "index_inventory_scans_on_supplier_id"
    t.index ["supplier_item_id"], name: "index_inventory_scans_on_supplier_item_id"
  end

  create_table "inventory_sessions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "supplier_id"
    t.boolean "archived", default: false, null: false
    t.index ["supplier_id"], name: "index_inventory_sessions_on_supplier_id"
  end

  create_table "supplier_items", force: :cascade do |t|
    t.integer "supplier_id", null: false
    t.string "ean"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ean"], name: "index_supplier_items_on_ean"
    t.index ["supplier_id"], name: "index_supplier_items_on_supplier_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "inventory_scans", "inventory_sessions"
  add_foreign_key "inventory_scans", "supplier_items"
  add_foreign_key "inventory_scans", "suppliers"
  add_foreign_key "inventory_sessions", "suppliers"
  add_foreign_key "supplier_items", "suppliers"
end
