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

ActiveRecord::Schema[8.0].define(version: 2025_03_27_175401) do
  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.string "cpf"
    t.string "phone"
    t.date "birthdate"
    t.string "address"
    t.string "postal_code"
    t.string "neighborhood"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "odontogram_path"
  end

  create_table "procedure_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "procedures", force: :cascade do |t|
    t.integer "client_id", null: false
    t.text "observation"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "teeth"
    t.integer "procedure_type_id"
    t.index ["client_id"], name: "index_procedures_on_client_id"
    t.index ["procedure_type_id"], name: "index_procedures_on_procedure_type_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "procedures", "clients"
  add_foreign_key "procedures", "procedure_types"
end
