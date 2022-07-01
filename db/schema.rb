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

ActiveRecord::Schema.define(version: 2022_06_27_154713) do

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
    t.text "cover_photo_data"
    t.jsonb "cover_photo_versions_data"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_categories_on_deleted_at"
  end

  create_table "cm_page_builder_rails_page_components", force: :cascade do |t|
    t.string "uuid", null: false
    t.bigint "page_id", null: false
    t.string "content"
    t.integer "position"
    t.string "component_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["page_id"], name: "index_cm_page_builder_rails_page_components_on_page_id"
  end

  create_table "cm_page_builder_rails_pages", force: :cascade do |t|
    t.string "container_type", null: false
    t.bigint "container_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["container_type", "container_id"], name: "container_composite_index"
  end

  create_table "constants", force: :cascade do |t|
    t.string "name"
    t.integer "constant_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "parent_id"
  end

  create_table "consultation_hindi_summaries", force: :cascade do |t|
    t.bigint "consultation_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["consultation_id"], name: "index_consultation_hindi_summaries_on_consultation_id"
  end

  create_table "consultation_response_votes", force: :cascade do |t|
    t.bigint "consultation_response_id", null: false
    t.integer "vote_direction"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["consultation_response_id", "user_id"], name: "consultation_response_id_and_user_id_index", unique: true
    t.index ["consultation_response_id"], name: "index_consultation_response_votes_on_consultation_response_id"
    t.index ["user_id"], name: "index_consultation_response_votes_on_user_id"
  end

  create_table "consultation_responses", force: :cascade do |t|
    t.bigint "user_id"
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
    t.jsonb "answers"
    t.datetime "deleted_at"
    t.bigint "respondent_id"
    t.bigint "response_round_id"
    t.string "import_key"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.bigint "phone_number"
    t.date "responded_at"
    t.integer "source", default: 0
    t.integer "response_status", default: 0
    t.jsonb "meta"
    t.index ["consultation_id"], name: "index_consultation_responses_on_consultation_id"
    t.index ["deleted_at"], name: "index_consultation_responses_on_deleted_at"
    t.index ["respondent_id"], name: "index_consultation_responses_on_respondent_id"
    t.index ["response_round_id"], name: "index_consultation_responses_on_response_round_id"
    t.index ["user_id"], name: "index_consultation_responses_on_user_id"
  end

  create_table "consultations", force: :cascade do |t|
    t.string "title", null: false
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
    t.integer "review_type", default: 0
    t.integer "visibility", default: 0
    t.integer "organisation_id"
    t.integer "private_response", default: 0
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_consultations_on_deleted_at"
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

  create_table "glossary_word_consultation_mappings", force: :cascade do |t|
    t.integer "consultation_id"
    t.integer "glossary_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.integer "parent_id"
    t.integer "location_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_international_city", default: false
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
    t.text "logo_data"
    t.jsonb "logo_versions_data"
    t.datetime "deleted_at"
    t.integer "location_id", default: 0
    t.index ["deleted_at"], name: "index_ministries_on_deleted_at"
  end

  create_table "notification_settings", force: :cascade do |t|
    t.boolean "on_new_consultation"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_notification_settings_on_user_id"
  end

  create_table "notification_types", force: :cascade do |t|
    t.string "notification_type"
    t.string "notification_main_text"
    t.string "notification_sub_text"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["notification_type"], name: "index_notification_types_on_notification_type", unique: true
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "datarefId"
    t.string "dataref"
    t.string "oldvalue"
    t.datetime "lastchangedatetime"
    t.string "datasource"
    t.boolean "status"
    t.bigint "userid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "organisations", force: :cascade do |t|
    t.string "name"
    t.text "logo_data"
    t.integer "created_by_id"
    t.integer "users_count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "active", default: true
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_organisations_on_deleted_at"
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

  create_table "profanities", force: :cascade do |t|
    t.string "profane_word"
    t.integer "created_by_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["profane_word"], name: "index_profanities_on_profane_word", unique: true
  end

  create_table "questions", force: :cascade do |t|
    t.integer "parent_id"
    t.string "question_text"
    t.integer "question_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.bigint "response_round_id"
    t.boolean "is_optional", default: false
    t.boolean "supports_other", default: false
    t.index ["deleted_at"], name: "index_questions_on_deleted_at"
    t.index ["response_round_id"], name: "index_questions_on_response_round_id"
  end

  create_table "respondents", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "response_round_id"
    t.bigint "organisation_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["organisation_id"], name: "index_respondents_on_organisation_id"
    t.index ["response_round_id"], name: "index_respondents_on_response_round_id"
    t.index ["user_id"], name: "index_respondents_on_user_id"
  end

  create_table "response_rounds", force: :cascade do |t|
    t.bigint "consultation_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "round_number"
    t.index ["consultation_id"], name: "index_response_rounds_on_consultation_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "temps", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_counts", force: :cascade do |t|
    t.integer "user_id"
    t.integer "profanity_count"
    t.integer "short_response_count"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_counts_on_user_id", unique: true
  end

  create_table "user_notifications", force: :cascade do |t|
    t.integer "user_id"
    t.string "notification_type"
    t.integer "consultation_id"
    t.integer "old_rank"
    t.boolean "notification_status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id", "notification_type", "consultation_id"], name: "user_id_notification_type_and_consultation_id_index", unique: true
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
    t.datetime "last_activity_at", default: -> { "(CURRENT_DATE)::timestamp without time zone" }
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
    t.text "profile_picture_data"
    t.jsonb "profile_picture_versions_data"
    t.string "organization"
    t.string "callback_url"
    t.string "designation"
    t.bigint "organisation_id"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.boolean "active", default: true
    t.integer "referring_consultation_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["organisation_id"], name: "index_users_on_organisation_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "wordindices", force: :cascade do |t|
    t.string "word"
    t.string "description"
    t.integer "created_by_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["word"], name: "index_wordindices_on_word", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "api_keys", "users"
  add_foreign_key "cm_page_builder_rails_page_components", "cm_page_builder_rails_pages", column: "page_id"
  add_foreign_key "consultation_hindi_summaries", "consultations"
  add_foreign_key "consultation_response_votes", "consultation_responses"
  add_foreign_key "consultation_response_votes", "users"
  add_foreign_key "consultation_responses", "consultations"
  add_foreign_key "consultation_responses", "respondents"
  add_foreign_key "consultation_responses", "response_rounds"
  add_foreign_key "consultation_responses", "users"
  add_foreign_key "consultations", "ministries"
  add_foreign_key "game_actions", "point_events"
  add_foreign_key "game_actions", "users"
  add_foreign_key "notification_settings", "users"
  add_foreign_key "point_events", "point_scales"
  add_foreign_key "point_events", "users"
  add_foreign_key "questions", "response_rounds"
  add_foreign_key "respondents", "organisations"
  add_foreign_key "respondents", "response_rounds"
  add_foreign_key "respondents", "users"
  add_foreign_key "response_rounds", "consultations"
  add_foreign_key "users", "organisations"
end
