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

ActiveRecord::Schema[8.0].define(version: 2025_12_23_165110) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "audit_logs", force: :cascade do |t|
    t.string "action", null: false
    t.string "auditable_type", null: false
    t.integer "auditable_id", null: false
    t.string "user_identifier"
    t.string "ip_address"
    t.text "user_agent"
    t.text "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable_type_and_auditable_id"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["user_identifier"], name: "index_audit_logs_on_user_identifier"
  end

  create_table "people", force: :cascade do |t|
    t.string "first_name", limit: 50, null: false
    t.string "middle_name", limit: 50
    t.string "last_name", limit: 50, null: false
    t.string "ssn", null: false
    t.string "street_address_1", null: false
    t.string "street_address_2"
    t.string "city", null: false
    t.string "state", limit: 2, null: false
    t.string "zip_code", limit: 5, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_people_on_created_at"
    t.index ["last_name"], name: "index_people_on_last_name"
  end
end
