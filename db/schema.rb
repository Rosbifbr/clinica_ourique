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

ActiveRecord::Schema[8.0].define(version: 2025_05_28_041151) do
  create_table "billings", force: :cascade do |t|
    t.integer "client_id", null: false
    t.integer "operation_id"
    t.decimal "amount"
    t.date "due_date"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_billings_on_client_id"
    t.index ["operation_id"], name: "index_billings_on_operation_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "name", null: false
    t.string "cpf", null: false
    t.string "phone"
    t.date "birthdate"
    t.string "address"
    t.string "postal_code"
    t.string "neighborhood"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "dental_map_image_base64"
    t.index ["cpf"], name: "index_clients_on_cpf", unique: true
    t.index ["name"], name: "index_clients_on_name"
  end

  create_table "operations", force: :cascade do |t|
    t.integer "client_id", null: false
    t.text "description"
    t.date "date"
    t.decimal "cost"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_operations_on_client_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", null: false
    t.string "password_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "billings", "clients"
  add_foreign_key "billings", "operations"
  add_foreign_key "operations", "clients"
end
