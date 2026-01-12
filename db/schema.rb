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

ActiveRecord::Schema[7.1].define(version: 2026_01_12_091434) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "uuid-ossp"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

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

  create_table "api_keys", force: :cascade do |t|
    t.string "access_token"
    t.datetime "created_at", null: false
    t.datetime "expires_at", precision: nil
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_api_keys_on_user_id"
  end

  create_table "case_studies", force: :cascade do |t|
    t.integer "case_study_type"
    t.datetime "created_at", null: false
    t.integer "created_by_id"
    t.string "ministry_name"
    t.string "name"
    t.integer "no_of_citizens"
    t.bigint "theme_id"
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["theme_id"], name: "index_case_studies_on_theme_id"
  end

  create_table "cm_comments", force: :cascade do |t|
    t.bigint "commentable_id"
    t.string "commentable_type"
    t.bigint "commenter_id"
    t.string "commenter_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_cm_comments_on_commentable"
    t.index ["commenter_type", "commenter_id"], name: "index_cm_comments_on_commenter"
  end

  create_table "cm_cron_job_logs", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.bigint "cron_job_id", null: false
    t.text "execution_log"
    t.datetime "started_at"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["cron_job_id"], name: "index_cm_cron_job_logs_on_cron_job_id"
  end

  create_table "cm_cron_jobs", force: :cascade do |t|
    t.string "command", null: false
    t.datetime "created_at", null: false
    t.string "cron_string", null: false
    t.datetime "last_run_at"
    t.string "name", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
  end

  create_table "cm_geo_ip_locations", force: :cascade do |t|
    t.string "continent_code"
    t.string "continent_name"
    t.string "country_iso_code"
    t.string "country_name"
    t.boolean "is_in_european_union"
    t.string "locale_code", null: false
    t.index ["country_iso_code"], name: "index_cm_geo_ip_locations_on_country_iso_code"
    t.index ["locale_code"], name: "index_cm_geo_ip_locations_on_locale_code"
  end

  create_table "cm_geo_ip_networks", force: :cascade do |t|
    t.bigint "cm_geo_ip_location_id"
    t.boolean "is_anonymous_proxy"
    t.boolean "is_anycast"
    t.boolean "is_satellite_provider"
    t.cidr "network", null: false
    t.integer "registered_country_geoname_id"
    t.integer "represented_country_geoname_id"
    t.index ["cm_geo_ip_location_id"], name: "index_cm_geo_ip_networks_on_cm_geo_ip_location_id"
    t.index ["network"], name: "index_cm_geo_ip_networks_on_network", using: :gist
  end

  create_table "cm_index_preferences", force: :cascade do |t|
    t.string "ar_model_name", null: false
    t.string "associated_ar_model_name"
    t.datetime "created_at", null: false
    t.string "hidden_columns", default: [], array: true
    t.integer "records_per_page", default: 20
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.string "visible_columns", default: [], array: true
    t.index ["ar_model_name"], name: "index_cm_index_preferences_on_ar_model_name"
    t.index ["associated_ar_model_name"], name: "index_cm_index_preferences_on_associated_ar_model_name"
    t.index ["user_id"], name: "index_cm_index_preferences_on_user_id"
  end

  create_table "cm_page_builder_rails_page_components", id: :string, force: :cascade do |t|
    t.string "component_type"
    t.string "content"
    t.datetime "created_at", null: false
    t.bigint "page_id", null: false
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["page_id"], name: "index_cm_page_builder_rails_page_components_on_page_id"
  end

  create_table "cm_page_builder_rails_pages", force: :cascade do |t|
    t.bigint "container_id", null: false
    t.string "container_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["container_type", "container_id"], name: "container_composite_index"
  end

  create_table "cm_permissions", force: :cascade do |t|
    t.string "action_display_name"
    t.string "action_name"
    t.string "ar_model_name"
    t.bigint "cm_role_id", null: false
    t.datetime "created_at", null: false
    t.string "scope_name"
    t.datetime "updated_at", null: false
    t.index ["ar_model_name", "action_name", "cm_role_id"], name: "index_cm_permissions_on_model_action_role", unique: true
    t.index ["cm_role_id"], name: "index_cm_permissions_on_cm_role_id"
  end

  create_table "cm_platform_settings", force: :cascade do |t|
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.string "created_by_type"
    t.text "description"
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.bigint "updated_by_id"
    t.string "updated_by_type"
    t.text "value"
    t.index ["category_id"], name: "index_cm_platform_settings_on_category_id"
    t.index ["created_by_type", "created_by_id"], name: "index_cm_platform_settings_on_created_by"
    t.index ["slug"], name: "index_cm_platform_settings_on_slug"
    t.index ["updated_by_type", "updated_by_id"], name: "index_cm_platform_settings_on_updated_by"
  end

  create_table "cm_roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "default_redirect_path", default: "/cm_admin/users"
    t.string "name"
    t.string "string", default: "/cm_admin/users"
    t.datetime "updated_at", null: false
  end

  create_table "cm_user_mentions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "mentionable_id"
    t.string "mentionable_type"
    t.bigint "mentioned_id"
    t.string "mentioned_type"
    t.datetime "updated_at", null: false
    t.index ["mentionable_type", "mentionable_id"], name: "index_cm_user_mentions_on_mentionable"
    t.index ["mentioned_type", "mentioned_id"], name: "index_cm_user_mentions_on_mentioned"
  end

  create_table "constant_maps", force: :cascade do |t|
    t.bigint "constant_id", null: false
    t.datetime "created_at", null: false
    t.bigint "mappable_id"
    t.string "mappable_type"
    t.datetime "updated_at", null: false
    t.index ["constant_id"], name: "index_constant_maps_on_constant_id"
    t.index ["mappable_type", "mappable_id"], name: "index_constant_maps_on_mappable"
  end

  create_table "constants", force: :cascade do |t|
    t.integer "constant_type"
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "parent_id"
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "vote_direction"
    t.index ["consultation_response_id"], name: "index_consultation_response_votes_on_consultation_response_id"
    t.index ["user_id"], name: "index_consultation_response_votes_on_user_id"
  end

  create_table "consultation_responses", force: :cascade do |t|
    t.jsonb "answers"
    t.bigint "consultation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at", precision: nil
    t.integer "down_vote_count", default: 0, null: false
    t.string "email"
    t.string "first_name"
    t.string "import_key"
    t.string "last_name"
    t.jsonb "meta"
    t.integer "objective_answer_count"
    t.bigint "organisation_id"
    t.bigint "phone_number"
    t.float "points", default: 0.0
    t.integer "reading_time", default: 0
    t.date "responded_at"
    t.bigint "respondent_id"
    t.string "response_language"
    t.bigint "response_round_id"
    t.integer "response_status", default: 0
    t.integer "satisfaction_rating"
    t.integer "source", default: 0
    t.integer "subjective_answer_count"
    t.integer "template_id"
    t.integer "templates_count", default: 0
    t.integer "up_vote_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.integer "visibility", default: 1
    t.jsonb "voice_responses", default: {}
    t.index ["consultation_id"], name: "index_consultation_responses_on_consultation_id"
    t.index ["deleted_at"], name: "index_consultation_responses_on_deleted_at"
    t.index ["organisation_id"], name: "index_consultation_responses_on_organisation_id"
    t.index ["respondent_id"], name: "index_consultation_responses_on_respondent_id"
    t.index ["response_round_id"], name: "index_consultation_responses_on_response_round_id"
    t.index ["response_status", "visibility"], name: "index_consultation_responses_on_response_status_and_visibility"
    t.index ["user_id"], name: "index_consultation_responses_on_user_id"
  end

  create_table "consultations", force: :cascade do |t|
    t.string "consultation_feedback_email"
    t.integer "consultation_responses_count", default: 0
    t.datetime "created_at", null: false
    t.integer "created_by_id"
    t.datetime "deleted_at", precision: nil
    t.bigint "department_id", null: false
    t.datetime "feedback_email_clicked_at"
    t.datetime "feedback_email_delivered_at"
    t.string "feedback_email_message_id"
    t.datetime "feedback_email_opened_at"
    t.boolean "is_featured", default: false
    t.boolean "is_satisfaction_rating_optional", default: false, null: false
    t.string "officer_designation"
    t.string "officer_name"
    t.integer "organisation_id"
    t.integer "private_response", default: 0
    t.datetime "published_at", precision: nil
    t.integer "question_flow", default: 0
    t.integer "reading_time", default: 0
    t.datetime "response_deadline", precision: nil
    t.uuid "response_token"
    t.integer "review_type", default: 0
    t.boolean "show_discuss_section", default: true, null: false
    t.boolean "show_satisfaction_rating", default: true
    t.integer "status", default: 0
    t.bigint "theme_id"
    t.string "title", null: false
    t.string "title_hindi"
    t.string "title_marathi"
    t.string "title_odia"
    t.datetime "updated_at", null: false
    t.string "url"
    t.integer "visibility", default: 0
    t.index ["deleted_at"], name: "index_consultations_on_deleted_at"
    t.index ["department_id"], name: "index_consultations_on_department_id"
    t.index ["feedback_email_message_id"], name: "index_consultations_on_feedback_email_message_id"
    t.index ["theme_id"], name: "index_consultations_on_theme_id"
  end

  create_table "department_contacts", force: :cascade do |t|
    t.integer "contact_type"
    t.datetime "created_at", null: false
    t.bigint "department_id", null: false
    t.string "designation"
    t.string "email"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_department_contacts_on_department_id"
  end

  create_table "departments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "created_by_id"
    t.datetime "deleted_at", precision: nil
    t.boolean "is_approved", default: false
    t.integer "level"
    t.integer "location_id", default: 0
    t.jsonb "meta"
    t.string "name"
    t.string "name_hindi"
    t.string "name_marathi"
    t.string "name_odia"
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_departments_on_deleted_at"
  end

  create_table "file_exports", force: :cascade do |t|
    t.string "action_name"
    t.integer "associated_model_id"
    t.string "associated_model_name"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.jsonb "error_report", default: {}
    t.datetime "expires_at"
    t.integer "export_type", default: 0
    t.bigint "exported_by_id", null: false
    t.string "exported_by_type", null: false
    t.jsonb "params", default: {}
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["exported_by_type", "exported_by_id"], name: "index_file_exports_on_exported_by"
  end

  create_table "file_imports", force: :cascade do |t|
    t.bigint "added_by_id", null: false
    t.string "added_by_type", null: false
    t.bigint "associated_model_id"
    t.string "associated_model_name"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.jsonb "error_report", default: {}
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["added_by_type", "added_by_id"], name: "index_file_imports_on_added_by"
  end

  create_table "game_actions", force: :cascade do |t|
    t.integer "action"
    t.datetime "created_at", null: false
    t.bigint "point_event_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["point_event_id"], name: "index_game_actions_on_point_event_id"
    t.index ["user_id"], name: "index_game_actions_on_user_id"
  end

  create_table "glossary_word_consultation_mappings", force: :cascade do |t|
    t.integer "consultation_id"
    t.datetime "created_at", null: false
    t.integer "glossary_id"
    t.datetime "updated_at", null: false
  end

  create_table "locations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_international_city", default: false
    t.integer "location_type"
    t.string "name"
    t.integer "parent_id"
    t.datetime "updated_at", null: false
    t.index ["location_type"], name: "index_locations_on_location_type"
    t.index ["parent_id"], name: "index_locations_on_parent_id"
  end

  create_table "notification_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "on_new_consultation"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_notification_settings_on_user_id"
  end

  create_table "organisations", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.integer "created_by_id"
    t.datetime "deleted_at", precision: nil
    t.integer "engagement_type"
    t.string "name"
    t.string "official_url"
    t.datetime "updated_at", null: false
    t.integer "users_count", default: 0
    t.index ["deleted_at"], name: "index_organisations_on_deleted_at"
  end

  create_table "otp_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expired_at"
    t.string "otp"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.datetime "verified_at"
    t.index ["user_id"], name: "index_otp_requests_on_user_id"
  end

  create_table "point_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "point_scale_id", null: false
    t.float "points"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["point_scale_id"], name: "index_point_events_on_point_scale_id"
    t.index ["user_id"], name: "index_point_events_on_user_id"
  end

  create_table "point_scales", force: :cascade do |t|
    t.integer "action"
    t.datetime "created_at", null: false
    t.float "points"
    t.datetime "updated_at", null: false
    t.integer "upper_limit"
  end

  create_table "profanities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "created_by_id"
    t.string "profane_word"
    t.datetime "updated_at", null: false
    t.index ["profane_word"], name: "index_profanities_on_profane_word", unique: true
  end

  create_table "questions", force: :cascade do |t|
    t.boolean "accept_voice_message", default: false
    t.bigint "conditional_question_id"
    t.datetime "created_at", null: false
    t.datetime "deleted_at", precision: nil
    t.boolean "has_choice_priority", default: false
    t.boolean "is_optional", default: false
    t.integer "parent_id"
    t.integer "position"
    t.string "question_text"
    t.string "question_text_hindi"
    t.text "question_text_marathi"
    t.string "question_text_odia"
    t.integer "question_type"
    t.bigint "response_round_id"
    t.integer "selected_options_limit"
    t.boolean "supports_other", default: false
    t.datetime "updated_at", null: false
    t.index ["conditional_question_id"], name: "index_questions_on_conditional_question_id"
    t.index ["deleted_at"], name: "index_questions_on_deleted_at"
    t.index ["parent_id"], name: "index_questions_on_parent_id"
    t.index ["response_round_id"], name: "index_questions_on_response_round_id"
  end

  create_table "respondents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "organisation_id"
    t.bigint "response_round_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["organisation_id"], name: "index_respondents_on_organisation_id"
    t.index ["response_round_id"], name: "index_respondents_on_response_round_id"
    t.index ["user_id"], name: "index_respondents_on_user_id"
  end

  create_table "response_rounds", force: :cascade do |t|
    t.bigint "consultation_id"
    t.datetime "created_at", null: false
    t.integer "round_number"
    t.datetime "updated_at", null: false
    t.index ["consultation_id"], name: "index_response_rounds_on_consultation_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "data"
    t.string "session_id", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "team_members", force: :cascade do |t|
    t.string "name"
    t.string "designation"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "linkedin_url"
    t.integer "member_type", default: 0, null: false
    t.index ["member_type"], name: "index_team_members_on_member_type"
  end

  create_table "themes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at", precision: nil
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_themes_on_deleted_at"
  end

  create_table "translations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "interpolations"
    t.boolean "is_proc", default: false
    t.string "key"
    t.string "locale"
    t.string "scope"
    t.datetime "updated_at", null: false
    t.text "value"
  end

  create_table "user_counts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "profanity_count"
    t.integer "short_response_count"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_user_counts_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active", default: true
    t.integer "best_rank"
    t.integer "best_rank_type"
    t.string "callback_url"
    t.integer "city_id"
    t.integer "city_rank"
    t.bigint "cm_role_id"
    t.datetime "confirmation_sent_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", null: false
    t.string "current_ip"
    t.datetime "current_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.string "designation"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "first_name"
    t.datetime "invitation_accepted_at", precision: nil
    t.datetime "invitation_created_at", precision: nil
    t.integer "invitation_limit"
    t.datetime "invitation_sent_at", precision: nil
    t.string "invitation_token"
    t.integer "invitations_count", default: 0
    t.bigint "invited_by_id"
    t.string "invited_by_type"
    t.datetime "last_active_at"
    t.datetime "last_activity_at", precision: nil, default: -> { "(CURRENT_DATE)::timestamp without time zone" }
    t.string "last_name"
    t.datetime "last_sign_in_at", precision: nil
    t.inet "last_sign_in_ip"
    t.string "locale", default: "en"
    t.datetime "locked_at", precision: nil
    t.jsonb "notification_settings", default: {"newsletter_subscription" => true, "notify_for_new_consultation" => true}
    t.bigint "organisation_id"
    t.string "organization"
    t.string "phone_number"
    t.float "points", default: 0.0
    t.string "provider"
    t.integer "rank"
    t.integer "referring_consultation_id"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.integer "role", default: 0
    t.integer "sign_in_count", default: 0, null: false
    t.string "sign_up_ip"
    t.integer "state_rank"
    t.string "uid"
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }, null: false
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
    t.datetime "created_at"
    t.string "event", null: false
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.text "object"
    t.text "object_changes"
    t.string "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "wordindices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "created_by_id"
    t.string "description"
    t.datetime "updated_at", null: false
    t.string "word"
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
  add_foreign_key "cm_platform_settings", "constants", column: "category_id"
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
  add_foreign_key "consultations", "themes"
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
