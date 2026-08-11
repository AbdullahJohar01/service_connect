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

ActiveRecord::Schema[8.1].define(version: 2026_08_10_210517) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "availabilities", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.integer "day_of_week", null: false
    t.time "end_time", null: false
    t.bigint "provider_profile_id", null: false
    t.time "start_time", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_profile_id"], name: "index_availabilities_on_provider_profile_id"
  end

  create_table "customer_profiles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "preferred_language"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_customer_profiles_on_user_id"
  end

  create_table "provider_profiles", force: :cascade do |t|
    t.integer "approval_status", default: 0, null: false
    t.decimal "average_rating", precision: 3, scale: 2, default: "0.0"
    t.string "business_name", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "experience_years", default: 0
    t.decimal "hourly_rate", precision: 10, scale: 2
    t.integer "total_reviews", default: 0
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_provider_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "email_verified_at"
    t.string "first_name"
    t.datetime "last_login_at"
    t.string "last_name"
    t.string "password_digest"
    t.string "phone_number"
    t.integer "role", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "availabilities", "provider_profiles"
  add_foreign_key "customer_profiles", "users"
  add_foreign_key "provider_profiles", "users"
end
