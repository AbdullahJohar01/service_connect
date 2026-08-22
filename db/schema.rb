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

ActiveRecord::Schema[8.1].define(version: 2026_08_22_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activity_logs", force: :cascade do |t|
    t.string "action", null: false
    t.bigint "actor_id"
    t.datetime "created_at", null: false
    t.jsonb "metadata", default: {}, null: false
    t.bigint "subject_id"
    t.string "subject_type"
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_activity_logs_on_action"
    t.index ["actor_id"], name: "index_activity_logs_on_actor_id"
    t.index ["subject_type", "subject_id"], name: "index_activity_logs_on_subject"
  end

  create_table "addresses", force: :cascade do |t|
    t.string "city"
    t.datetime "created_at", null: false
    t.boolean "is_default"
    t.string "label"
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "postal_code"
    t.string "street"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

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

  create_table "booking_status_histories", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.bigint "changed_by_id", null: false
    t.datetime "created_at", null: false
    t.integer "new_status", null: false
    t.text "notes"
    t.integer "previous_status"
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_booking_status_histories_on_booking_id"
    t.index ["changed_by_id"], name: "index_booking_status_histories_on_changed_by_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.datetime "accepted_at"
    t.bigint "address_id", null: false
    t.text "cancellation_reason"
    t.datetime "cancelled_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.text "customer_description"
    t.bigint "customer_id", null: false
    t.integer "estimated_duration"
    t.decimal "estimated_price"
    t.decimal "final_price"
    t.bigint "provider_id", null: false
    t.text "provider_notes"
    t.datetime "scheduled_at"
    t.bigint "service_category_id", null: false
    t.datetime "started_at"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_bookings_on_address_id"
    t.index ["customer_id"], name: "index_bookings_on_customer_id"
    t.index ["provider_id", "scheduled_at"], name: "index_bookings_on_provider_id_and_scheduled_at"
    t.index ["provider_id"], name: "index_bookings_on_provider_id"
    t.index ["service_category_id"], name: "index_bookings_on_service_category_id"
  end

  create_table "customer_profiles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "preferred_language"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_customer_profiles_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.bigint "sender_id", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_messages_on_booking_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.datetime "created_at", null: false
    t.text "message", null: false
    t.string "notification_type", null: false
    t.boolean "read", default: false, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["booking_id"], name: "index_notifications_on_booking_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "password_reset_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.datetime "used_at"
    t.bigint "user_id", null: false
    t.index ["token_digest"], name: "index_password_reset_tokens_on_token_digest", unique: true
    t.index ["user_id"], name: "index_password_reset_tokens_on_user_id"
  end

  create_table "provider_profiles", force: :cascade do |t|
    t.integer "approval_status", default: 0, null: false
    t.decimal "average_rating", precision: 3, scale: 2, default: "0.0"
    t.string "business_name", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "experience_years", default: 0
    t.decimal "hourly_rate", precision: 10, scale: 2
    t.text "rejection_reason"
    t.integer "total_reviews", default: 0
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_provider_profiles_on_user_id"
  end

  create_table "provider_services", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.decimal "base_price", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "duration_minutes", null: false
    t.bigint "provider_profile_id", null: false
    t.bigint "service_category_id", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_profile_id"], name: "index_provider_services_on_provider_profile_id"
    t.index ["service_category_id"], name: "index_provider_services_on_service_category_id"
  end

  create_table "refresh_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.datetime "revoked_at"
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["token_digest"], name: "index_refresh_tokens_on_token_digest", unique: true
    t.index ["user_id"], name: "index_refresh_tokens_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.bigint "provider_id", null: false
    t.integer "rating", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_reviews_on_booking_id", unique: true
    t.index ["customer_id"], name: "index_reviews_on_customer_id"
    t.index ["provider_id"], name: "index_reviews_on_provider_id"
  end

  create_table "service_categories", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activity_logs", "users", column: "actor_id"
  add_foreign_key "addresses", "users"
  add_foreign_key "availabilities", "provider_profiles"
  add_foreign_key "booking_status_histories", "bookings"
  add_foreign_key "booking_status_histories", "users", column: "changed_by_id"
  add_foreign_key "bookings", "addresses"
  add_foreign_key "bookings", "provider_profiles", column: "provider_id"
  add_foreign_key "bookings", "service_categories"
  add_foreign_key "bookings", "users", column: "customer_id"
  add_foreign_key "customer_profiles", "users"
  add_foreign_key "messages", "bookings"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "notifications", "bookings"
  add_foreign_key "notifications", "users"
  add_foreign_key "password_reset_tokens", "users"
  add_foreign_key "provider_profiles", "users"
  add_foreign_key "provider_services", "provider_profiles"
  add_foreign_key "provider_services", "service_categories"
  add_foreign_key "refresh_tokens", "users"
  add_foreign_key "reviews", "bookings"
  add_foreign_key "reviews", "provider_profiles", column: "provider_id"
  add_foreign_key "reviews", "users", column: "customer_id"
end
