# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20260121100000) do

  create_table "customers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.text     "address",        limit: 65535
    t.string   "aadhaar_or_pan"
    t.string   "gst_number"
    t.string   "email"
    t.string   "phone"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["email"], name: "index_customers_on_email", unique: true, using: :btree
    t.index ["phone"], name: "index_customers_on_phone", unique: true, using: :btree
  end

  create_table "inventory_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
    t.integer  "jewelry_item_id",             null: false
    t.integer  "available_grams", default: 0, null: false
    t.string   "location"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["jewelry_item_id"], name: "index_inventory_items_on_jewelry_item_id", using: :btree
  end

  create_table "jewellery_categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
    t.integer  "metal_id",                  null: false
    t.string   "name"
    t.boolean  "active",     default: true
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["metal_id"], name: "index_jewellery_categories_on_metal_id", using: :btree
  end

  create_table "jewelry_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
    t.string   "name",                                                                         null: false
    t.text     "description",           limit: 65535
    t.integer  "price_cents",                                                  default: 0,     null: false
    t.string   "sku",                                                                          null: false
    t.datetime "created_at",                                                                   null: false
    t.datetime "updated_at",                                                                   null: false
    t.string   "metal_type"
    t.integer  "metal_id"
    t.integer  "purity_id"
    t.integer  "jewellery_category_id"
    t.integer  "quantity",                                                     default: 0,     null: false
    t.decimal  "weight_grams",                        precision: 10, scale: 2, default: "0.0", null: false
    t.index ["jewellery_category_id"], name: "index_jewelry_items_on_jewellery_category_id", using: :btree
    t.index ["metal_id"], name: "index_jewelry_items_on_metal_id", using: :btree
    t.index ["purity_id"], name: "index_jewelry_items_on_purity_id", using: :btree
    t.index ["sku"], name: "index_jewelry_items_on_sku", unique: true, using: :btree
  end

  create_table "line_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
    t.integer  "order_id",                                                 null: false
    t.integer  "jewelry_item_id",                                          null: false
    t.integer  "price_cents",                              default: 0,     null: false
    t.integer  "quantity",                                 default: 1,     null: false
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.decimal  "weight",          precision: 10, scale: 2, default: "0.0"
    t.string   "hsn"
    t.decimal  "gross_weight",    precision: 10, scale: 2, default: "0.0"
    t.decimal  "net_weight",      precision: 10, scale: 2, default: "0.0"
    t.decimal  "making_charge",   precision: 12, scale: 2, default: "0.0"
    t.string   "huid"
    t.decimal  "rate",            precision: 12, scale: 2, default: "0.0"
    t.index ["jewelry_item_id"], name: "index_line_items_on_jewelry_item_id", using: :btree
    t.index ["order_id"], name: "index_line_items_on_order_id", using: :btree
  end

  create_table "metal_stock_movements", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
    t.integer  "metal_stock_id",               null: false
    t.integer  "change_grams",                 null: false
    t.string   "movement_type",                null: false
    t.text     "note",           limit: 65535
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["metal_stock_id"], name: "index_metal_stock_movements_on_metal_stock_id", using: :btree
  end

  create_table "metal_stocks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
    t.integer  "metal_id",                         null: false
    t.integer  "store_id",                         null: false
    t.integer  "available_grams",      default: 0, null: false
    t.integer  "price_cents_per_gram", default: 0, null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.index ["metal_id", "store_id"], name: "index_metal_stocks_on_metal_id_and_store_id", unique: true, using: :btree
    t.index ["metal_id"], name: "index_metal_stocks_on_metal_id", using: :btree
    t.index ["store_id"], name: "index_metal_stocks_on_store_id", using: :btree
  end

  create_table "metals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
    t.string   "name",                      null: false
    t.string   "base_unit"
    t.boolean  "active",     default: true
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "orders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
    t.string   "status",                                        default: "pending", null: false
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
    t.decimal  "discount",             precision: 10, scale: 2, default: "0.0"
    t.decimal  "charges",              precision: 10, scale: 2, default: "0.0"
    t.decimal  "gross_weight",         precision: 10, scale: 2, default: "0.0"
    t.decimal  "net_weight",           precision: 10, scale: 2, default: "0.0"
    t.decimal  "cgst_rate",            precision: 6,  scale: 2, default: "0.0"
    t.decimal  "igst_rate",            precision: 6,  scale: 2, default: "0.0"
    t.integer  "cgst_cents",                                    default: 0
    t.integer  "igst_cents",                                    default: 0
    t.string   "invoice_number"
    t.date     "sale_date"
    t.integer  "customer_id"
    t.datetime "stock_decremented_at"
    t.string   "payment_method"
    t.index ["customer_id"], name: "index_orders_on_customer_id", using: :btree
    t.index ["invoice_number"], name: "index_orders_on_invoice_number", unique: true, using: :btree
    t.index ["stock_decremented_at"], name: "index_orders_on_stock_decremented_at", using: :btree
  end

  create_table "purities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
    t.integer  "metal_id",                                                             null: false
    t.string   "name"
    t.decimal  "purity_percent",               precision: 8,  scale: 4
    t.boolean  "active",                                                default: true
    t.decimal  "updated_price",                precision: 12, scale: 2
    t.text     "remarks",        limit: 65535
    t.datetime "created_at",                                                           null: false
    t.datetime "updated_at",                                                           null: false
    t.index ["metal_id"], name: "index_purities_on_metal_id", using: :btree
  end

  create_table "rates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
    t.date     "date",                             null: false
    t.string   "metal_type",                       null: false
    t.integer  "price_cents_per_gram", default: 0, null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.index ["date", "metal_type"], name: "index_rates_on_date_and_metal_type", unique: true, using: :btree
  end

  create_table "stock_movements", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
    t.integer  "inventory_item_id", null: false
    t.integer  "change_grams",      null: false
    t.string   "movement_type",     null: false
    t.string   "note"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["inventory_item_id"], name: "index_stock_movements_on_inventory_item_id", using: :btree
  end

  create_table "stores", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
    t.string   "name",       null: false
    t.string   "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_stores_on_name", unique: true, using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "inventory_items", "jewelry_items"
  add_foreign_key "jewellery_categories", "metals"
  add_foreign_key "line_items", "jewelry_items"
  add_foreign_key "line_items", "orders"
  add_foreign_key "metal_stock_movements", "metal_stocks"
  add_foreign_key "metal_stocks", "metals"
  add_foreign_key "metal_stocks", "stores"
  add_foreign_key "orders", "customers"
  add_foreign_key "purities", "metals"
  add_foreign_key "stock_movements", "inventory_items"
end
