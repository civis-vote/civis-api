# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_03_09_093958) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

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
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "api_keys", force: :cascade do |t|
    t.string "access_token"
    t.bigint "user_id", null: false
    t.datetime "expires_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_api_keys_on_user_id"
  end

  create_table "case_studies", force: :cascade do |t|
    t.string "name"
    t.string "ministry_name"
    t.integer "no_of_citizens"
    t.string "url"
    t.integer "created_by_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "constants", force: :cascade do |t|
    t.string "name"
    t.integer "constant_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "parent_id"
  end

  create_table "consultation_response_votes", force: :cascade do |t|
    t.bigint "consultation_response_id", null: false
    t.integer "vote_direction"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["consultation_response_id"], name: "index_consultation_response_votes_on_consultation_response_id"
    t.index ["user_id"], name: "index_consultation_response_votes_on_user_id"
  end

  create_table "consultation_responses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "consultation_id", null: false
    t.integer "satisfaction_rating"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "visibility", default: 1
    t.integer "template_id"
    t.float "points", default: 0.0
    t.integer "templates_count", default: 0
    t.integer "reading_time", default: 0
    t.integer "up_vote_count", default: 0, null: false
    t.integer "down_vote_count", default: 0, null: false
    t.index ["consultation_id"], name: "index_consultation_responses_on_consultation_id"
    t.index ["user_id"], name: "index_consultation_responses_on_user_id"
  end

  create_table "consultations", force: :cascade do |t|
    t.string "title"
    t.string "url"
    t.datetime "response_deadline"
    t.bigint "ministry_id", null: false
    t.integer "status", default: 0
    t.integer "created_by_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "published_at"
    t.integer "consultation_responses_count", default: 0
    t.boolean "is_featured", default: false
    t.uuid "response_token"
    t.integer "reading_time", default: 0
    t.string "consultation_feedback_email"
    t.index ["ministry_id"], name: "index_consultations_on_ministry_id"
  end

  create_table "game_actions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "action"
    t.bigint "point_event_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["point_event_id"], name: "index_game_actions_on_point_event_id"
    t.index ["user_id"], name: "index_game_actions_on_user_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.integer "parent_id"
    t.integer "location_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "ministries", force: :cascade do |t|
    t.string "name"
    t.integer "category_id"
    t.integer "level"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_approved", default: false
    t.string "poc_email_primary"
    t.string "poc_email_secondary"
    t.integer "created_by_id"
    t.jsonb "meta"
  end

  create_table "notification_settings", force: :cascade do |t|
    t.boolean "on_new_consultation"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_notification_settings_on_user_id"
  end

  create_table "point_events", force: :cascade do |t|
    t.bigint "point_scale_id", null: false
    t.bigint "user_id", null: false
    t.float "points"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["point_scale_id"], name: "index_point_events_on_point_scale_id"
    t.index ["user_id"], name: "index_point_events_on_user_id"
  end

  create_table "point_scales", force: :cascade do |t|
    t.integer "upper_limit"
    t.integer "action"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "points"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "first_name"
    t.string "last_name"
    t.integer "city_id"
    t.datetime "last_activity_at", default: -> { "(('now'::text)::date)::timestamp without time zone" }
    t.jsonb "notification_settings"
    t.integer "role", default: 0
    t.string "phone_number"
    t.string "provider"
    t.string "uid"
    t.float "points", default: 0.0
    t.integer "rank"
    t.integer "state_rank"
    t.integer "city_rank"
    t.integer "best_rank"
    t.integer "best_rank_type"
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "api_keys", "users"
  add_foreign_key "consultation_response_votes", "consultation_responses"
  add_foreign_key "consultation_response_votes", "users"
  add_foreign_key "consultation_responses", "consultations"
  add_foreign_key "consultation_responses", "users"
  add_foreign_key "consultations", "ministries"
  add_foreign_key "game_actions", "point_events"
  add_foreign_key "game_actions", "users"
  add_foreign_key "notification_settings", "users"
  add_foreign_key "point_events", "point_scales"
  add_foreign_key "point_events", "users"
end
