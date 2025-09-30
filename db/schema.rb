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

ActiveRecord::Schema[7.1].define(version: 2025_09_26_051935) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "api_keys", force: :cascade do |t|
    t.string "access_token"
    t.bigint "user_id", null: false
    t.datetime "expires_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_api_keys_on_user_id"
  end

  create_table "case_studies", force: :cascade do |t|
    t.string "name"
    t.string "ministry_name"
    t.integer "no_of_citizens"
    t.string "url"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "case_study_type"
    t.bigint "theme_id"
    t.index ["theme_id"], name: "index_case_studies_on_theme_id"
  end

  create_table "cm_cron_job_logs", force: :cascade do |t|
    t.bigint "cron_job_id", null: false
    t.integer "status", default: 0, null: false
    t.text "execution_log"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cron_job_id"], name: "index_cm_cron_job_logs_on_cron_job_id"
  end

  create_table "cm_cron_jobs", force: :cascade do |t|
    t.string "name", null: false
    t.string "command", null: false
    t.string "cron_string", null: false
    t.datetime "last_run_at"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cm_geo_ip_locations", force: :cascade do |t|
    t.string "locale_code", null: false
    t.string "continent_code"
    t.string "continent_name"
    t.string "country_iso_code"
    t.string "country_name"
    t.boolean "is_in_european_union"
    t.index ["country_iso_code"], name: "index_cm_geo_ip_locations_on_country_iso_code"
    t.index ["locale_code"], name: "index_cm_geo_ip_locations_on_locale_code"
  end

  create_table "cm_geo_ip_networks", force: :cascade do |t|
    t.cidr "network", null: false
    t.bigint "cm_geo_ip_location_id"
    t.integer "registered_country_geoname_id"
    t.integer "represented_country_geoname_id"
    t.boolean "is_anonymous_proxy"
    t.boolean "is_satellite_provider"
    t.boolean "is_anycast"
    t.index ["cm_geo_ip_location_id"], name: "index_cm_geo_ip_networks_on_cm_geo_ip_location_id"
    t.index ["network"], name: "index_cm_geo_ip_networks_on_network", using: :gist
  end

  create_table "cm_index_preferences", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ar_model_name", null: false
    t.string "associated_ar_model_name"
    t.string "visible_columns", default: [], array: true
    t.string "hidden_columns", default: [], array: true
    t.integer "records_per_page", default: 20
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ar_model_name"], name: "index_cm_index_preferences_on_ar_model_name"
    t.index ["associated_ar_model_name"], name: "index_cm_index_preferences_on_associated_ar_model_name"
    t.index ["user_id"], name: "index_cm_index_preferences_on_user_id"
  end

  create_table "cm_page_builder_rails_page_components", id: :string, force: :cascade do |t|
    t.bigint "page_id", null: false
    t.string "content"
    t.integer "position"
    t.string "component_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["page_id"], name: "index_cm_page_builder_rails_page_components_on_page_id"
  end

  create_table "cm_page_builder_rails_pages", force: :cascade do |t|
    t.string "container_type", null: false
    t.bigint "container_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["container_type", "container_id"], name: "container_composite_index"
  end

  create_table "cm_permissions", force: :cascade do |t|
    t.string "action_name"
    t.string "action_display_name"
    t.string "ar_model_name"
    t.string "scope_name"
    t.bigint "cm_role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cm_role_id"], name: "index_cm_permissions_on_cm_role_id"
  end

  create_table "cm_roles", force: :cascade do |t|
    t.string "name"
    t.string "default_redirect_path", default: "/cm_admin/users"
    t.string "string", default: "/cm_admin/users"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "constant_maps", force: :cascade do |t|
    t.bigint "constant_id", null: false
    t.string "mappable_type"
    t.bigint "mappable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["constant_id"], name: "index_constant_maps_on_constant_id"
    t.index ["mappable_type", "mappable_id"], name: "index_constant_maps_on_mappable"
  end

  create_table "constants", force: :cascade do |t|
    t.string "name"
    t.integer "constant_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_id"
  end

  create_table "consultation_hindi_summaries", force: :cascade do |t|
    t.bigint "consultation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["consultation_id"], name: "index_consultation_hindi_summaries_on_consultation_id"
  end

  create_table "consultation_marathi_summaries", force: :cascade do |t|
    t.bigint "consultation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["consultation_id"], name: "index_consultation_marathi_summaries_on_consultation_id"
  end

  create_table "consultation_odia_summaries", force: :cascade do |t|
    t.bigint "consultation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["consultation_id"], name: "index_consultation_odia_summaries_on_consultation_id"
  end

  create_table "consultation_response_votes", force: :cascade do |t|
    t.bigint "consultation_response_id", null: false
    t.integer "vote_direction"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["consultation_response_id"], name: "index_consultation_response_votes_on_consultation_response_id"
    t.index ["user_id"], name: "index_consultation_response_votes_on_user_id"
  end

  create_table "consultation_responses", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "consultation_id", null: false
    t.integer "satisfaction_rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "visibility", default: 1
    t.integer "template_id"
    t.float "points", default: 0.0
    t.integer "templates_count", default: 0
    t.integer "reading_time", default: 0
    t.integer "up_vote_count", default: 0, null: false
    t.integer "down_vote_count", default: 0, null: false
    t.jsonb "answers"
    t.datetime "deleted_at", precision: nil
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
    t.integer "subjective_answer_count"
    t.integer "objective_answer_count"
    t.bigint "organisation_id"
    t.index ["consultation_id"], name: "index_consultation_responses_on_consultation_id"
    t.index ["deleted_at"], name: "index_consultation_responses_on_deleted_at"
    t.index ["organisation_id"], name: "index_consultation_responses_on_organisation_id"
    t.index ["respondent_id"], name: "index_consultation_responses_on_respondent_id"
    t.index ["response_round_id"], name: "index_consultation_responses_on_response_round_id"
    t.index ["response_status", "visibility"], name: "index_consultation_responses_on_response_status_and_visibility"
    t.index ["user_id"], name: "index_consultation_responses_on_user_id"
  end

  create_table "consultations", force: :cascade do |t|
    t.string "title", null: false
    t.string "url"
    t.datetime "response_deadline", precision: nil
    t.bigint "department_id", null: false
    t.integer "status", default: 0
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "published_at", precision: nil
    t.integer "consultation_responses_count", default: 0
    t.boolean "is_featured", default: false
    t.uuid "response_token"
    t.integer "reading_time", default: 0
    t.string "consultation_feedback_email"
    t.integer "review_type", default: 0
    t.integer "visibility", default: 0
    t.integer "organisation_id"
    t.integer "private_response", default: 0
    t.datetime "deleted_at", precision: nil
    t.string "officer_name"
    t.string "officer_designation"
    t.string "title_hindi"
    t.string "title_odia"
    t.boolean "is_satisfaction_rating_optional", default: false, null: false
    t.string "feedback_email_message_id"
    t.datetime "feedback_email_delivered_at"
    t.datetime "feedback_email_opened_at"
    t.datetime "feedback_email_clicked_at"
    t.string "title_marathi"
    t.boolean "show_discuss_section", default: true, null: false
    t.boolean "show_satisfaction_rating", default: true
    t.index ["deleted_at"], name: "index_consultations_on_deleted_at"
    t.index ["department_id"], name: "index_consultations_on_department_id"
    t.index ["feedback_email_message_id"], name: "index_consultations_on_feedback_email_message_id"
  end

  create_table "department_contacts", force: :cascade do |t|
    t.bigint "department_id", null: false
    t.string "name"
    t.string "email"
    t.string "designation"
    t.integer "contact_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_department_contacts_on_department_id"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name"
    t.bigint "theme_id"
    t.integer "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_approved", default: false
    t.integer "created_by_id"
    t.jsonb "meta"
    t.datetime "deleted_at", precision: nil
    t.integer "location_id", default: 0
    t.string "name_hindi"
    t.string "name_odia"
    t.string "name_marathi"
    t.index ["deleted_at"], name: "index_departments_on_deleted_at"
    t.index ["theme_id"], name: "index_departments_on_theme_id"
  end

  create_table "file_exports", force: :cascade do |t|
    t.string "associated_model_name"
    t.string "exported_by_type", null: false
    t.bigint "exported_by_id", null: false
    t.datetime "expires_at"
    t.integer "status", default: 0
    t.jsonb "params", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "associated_model_id"
    t.string "action_name"
    t.string "url"
    t.integer "export_type", default: 0
    t.datetime "completed_at"
    t.jsonb "error_report", default: {}
    t.index ["exported_by_type", "exported_by_id"], name: "index_file_exports_on_exported_by"
  end

  create_table "file_imports", force: :cascade do |t|
    t.string "associated_model_name"
    t.string "added_by_type", null: false
    t.bigint "added_by_id", null: false
    t.jsonb "error_report", default: {}
    t.datetime "completed_at"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "associated_model_id"
    t.index ["added_by_type", "added_by_id"], name: "index_file_imports_on_added_by"
  end

  create_table "game_actions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "action"
    t.bigint "point_event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["point_event_id"], name: "index_game_actions_on_point_event_id"
    t.index ["user_id"], name: "index_game_actions_on_user_id"
  end

  create_table "glossary_word_consultation_mappings", force: :cascade do |t|
    t.integer "consultation_id"
    t.integer "glossary_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.integer "parent_id"
    t.integer "location_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_international_city", default: false
    t.index ["location_type"], name: "index_locations_on_location_type"
    t.index ["parent_id"], name: "index_locations_on_parent_id"
  end

  create_table "notification_settings", force: :cascade do |t|
    t.boolean "on_new_consultation"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notification_settings_on_user_id"
  end

  create_table "organisations", force: :cascade do |t|
    t.string "name"
    t.integer "created_by_id"
    t.integer "users_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.datetime "deleted_at", precision: nil
    t.string "official_url"
    t.integer "engagement_type"
    t.index ["deleted_at"], name: "index_organisations_on_deleted_at"
  end

  create_table "otp_requests", force: :cascade do |t|
    t.string "otp"
    t.datetime "expired_at"
    t.integer "status"
    t.datetime "verified_at"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_otp_requests_on_user_id"
  end

  create_table "point_events", force: :cascade do |t|
    t.bigint "point_scale_id", null: false
    t.bigint "user_id", null: false
    t.float "points"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["point_scale_id"], name: "index_point_events_on_point_scale_id"
    t.index ["user_id"], name: "index_point_events_on_user_id"
  end

  create_table "point_scales", force: :cascade do |t|
    t.integer "upper_limit"
    t.integer "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "points"
  end

  create_table "profanities", force: :cascade do |t|
    t.string "profane_word"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profane_word"], name: "index_profanities_on_profane_word", unique: true
  end

  create_table "questions", force: :cascade do |t|
    t.integer "parent_id"
    t.string "question_text"
    t.integer "question_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at", precision: nil
    t.bigint "response_round_id"
    t.boolean "is_optional", default: false
    t.boolean "supports_other", default: false
    t.string "question_text_hindi"
    t.string "question_text_odia"
    t.text "question_text_marathi"
    t.integer "position"
    t.bigint "conditional_question_id"
    t.index ["conditional_question_id"], name: "index_questions_on_conditional_question_id"
    t.index ["deleted_at"], name: "index_questions_on_deleted_at"
    t.index ["parent_id"], name: "index_questions_on_parent_id"
    t.index ["response_round_id"], name: "index_questions_on_response_round_id"
  end

  create_table "respondents", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "response_round_id"
    t.bigint "organisation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organisation_id"], name: "index_respondents_on_organisation_id"
    t.index ["response_round_id"], name: "index_respondents_on_response_round_id"
    t.index ["user_id"], name: "index_respondents_on_user_id"
  end

  create_table "response_rounds", force: :cascade do |t|
    t.bigint "consultation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "round_number"
    t.index ["consultation_id"], name: "index_response_rounds_on_consultation_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "themes", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at", precision: nil
    t.index ["deleted_at"], name: "index_themes_on_deleted_at"
  end

  create_table "translations", force: :cascade do |t|
    t.string "scope"
    t.string "locale"
    t.string "key"
    t.text "value"
    t.text "interpolations"
    t.boolean "is_proc", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_counts", force: :cascade do |t|
    t.integer "user_id"
    t.integer "profanity_count"
    t.integer "short_response_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_counts_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.integer "city_id"
    t.datetime "last_activity_at", precision: nil, default: -> { "(CURRENT_DATE)::timestamp without time zone" }
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
    t.string "organization"
    t.string "callback_url"
    t.string "designation"
    t.bigint "organisation_id"
    t.string "invitation_token"
    t.datetime "invitation_created_at", precision: nil
    t.datetime "invitation_sent_at", precision: nil
    t.datetime "invitation_accepted_at", precision: nil
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.boolean "active", default: true
    t.integer "referring_consultation_id"
    t.bigint "cm_role_id"
    t.string "current_ip"
    t.string "sign_up_ip"
    t.datetime "last_active_at"
    t.string "locale", default: "en"
    t.index ["cm_role_id"], name: "index_users_on_cm_role_id"
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

  create_table "versions", force: :cascade do |t|
    t.string "whodunnit"
    t.datetime "created_at"
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.string "event", null: false
    t.text "object"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "wordindices", force: :cascade do |t|
    t.string "word"
    t.string "description"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["word"], name: "index_wordindices_on_word", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "api_keys", "users"
  add_foreign_key "case_studies", "themes"
  add_foreign_key "cm_cron_job_logs", "cm_cron_jobs", column: "cron_job_id"
  add_foreign_key "cm_geo_ip_networks", "cm_geo_ip_locations"
  add_foreign_key "cm_page_builder_rails_page_components", "cm_page_builder_rails_pages", column: "page_id"
  add_foreign_key "cm_permissions", "cm_roles"
  add_foreign_key "constant_maps", "constants"
  add_foreign_key "consultation_hindi_summaries", "consultations"
  add_foreign_key "consultation_marathi_summaries", "consultations"
  add_foreign_key "consultation_odia_summaries", "consultations"
  add_foreign_key "consultation_response_votes", "consultation_responses"
  add_foreign_key "consultation_response_votes", "users"
  add_foreign_key "consultation_responses", "consultations"
  add_foreign_key "consultation_responses", "organisations"
  add_foreign_key "consultation_responses", "respondents"
  add_foreign_key "consultation_responses", "response_rounds"
  add_foreign_key "consultation_responses", "users"
  add_foreign_key "consultations", "departments"
  add_foreign_key "department_contacts", "departments"
  add_foreign_key "game_actions", "point_events"
  add_foreign_key "game_actions", "users"
  add_foreign_key "notification_settings", "users"
  add_foreign_key "otp_requests", "users"
  add_foreign_key "point_events", "point_scales"
  add_foreign_key "point_events", "users"
  add_foreign_key "questions", "questions", column: "conditional_question_id"
  add_foreign_key "questions", "response_rounds"
  add_foreign_key "respondents", "organisations"
  add_foreign_key "respondents", "response_rounds"
  add_foreign_key "respondents", "users"
  add_foreign_key "response_rounds", "consultations"
  add_foreign_key "users", "cm_roles"
  add_foreign_key "users", "organisations"
end
