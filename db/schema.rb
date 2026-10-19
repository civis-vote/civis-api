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

ActiveRecord::Schema[8.1].define(version: 2026_10_19_130000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"
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
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
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
    t.bigint "user_id", null: false
    t.datetime "expires_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_api_keys_on_user_id"
  end

  create_table "api_tokens", force: :cascade do |t|
    t.string "token"
    t.integer "status", default: 0
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "token_type", default: 0, null: false
    t.datetime "expires_at"
    t.text "description"
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
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

  create_table "clause_feedbacks", force: :cascade do |t|
    t.bigint "clause_id", null: false
    t.bigint "consultation_response_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["clause_id"], name: "index_clause_feedbacks_on_clause_id"
    t.index ["consultation_response_id"], name: "index_clause_feedbacks_on_consultation_response_id"
  end

  create_table "clauses", force: :cascade do |t|
    t.string "clause_id", null: false
    t.string "clause_title", null: false
    t.string "stakeholder_impact"
    t.string "keywords"
    t.bigint "consultation_id", null: false
    t.bigint "clause_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "what_is_being_proposed"
    t.index ["clause_type_id"], name: "index_clauses_on_clause_type_id"
    t.index ["consultation_id"], name: "index_clauses_on_consultation_id"
  end

  create_table "cm_comments", force: :cascade do |t|
    t.string "commenter_type"
    t.bigint "commenter_id"
    t.string "commentable_type"
    t.bigint "commentable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "created_by_name"
    t.citext "created_by_email"
    t.index ["commentable_type", "commentable_id"], name: "index_cm_comments_on_commentable"
    t.index ["commenter_type", "commenter_id"], name: "index_cm_comments_on_commenter"
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
    t.text "notification_emails"
  end

  create_table "cm_email_logs", force: :cascade do |t|
    t.string "message_id"
    t.string "subject"
    t.text "to"
    t.text "cc"
    t.text "bcc"
    t.string "reply_to"
    t.string "from_email"
    t.string "from_name"
    t.integer "status", default: 0, null: false
    t.string "template_name"
    t.string "partial_file_path"
    t.string "in_reply_to"
    t.string "references"
    t.jsonb "delivery_method_options"
    t.jsonb "attachment_metadata"
    t.string "module_name"
    t.string "record_type"
    t.bigint "record_id"
    t.string "record_url"
    t.bigint "triggered_by_id"
    t.string "triggered_by_type"
    t.text "failure_reason"
    t.string "error_code"
    t.text "raw_error_response"
    t.datetime "failed_at"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_cm_email_logs_on_created_at"
    t.index ["message_id"], name: "index_cm_email_logs_on_message_id"
    t.index ["module_name"], name: "index_cm_email_logs_on_module_name"
    t.index ["record_type", "record_id"], name: "index_cm_email_logs_on_record"
    t.index ["status"], name: "index_cm_email_logs_on_status"
    t.index ["triggered_by_id"], name: "index_cm_email_logs_on_triggered_by_id"
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

  create_table "cm_notifiables", force: :cascade do |t|
    t.string "notifiable_type", null: false
    t.bigint "notifiable_id", null: false
    t.integer "notification_type", default: 0, null: false
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_cm_notifiables_on_notifiable"
    t.index ["notification_type"], name: "index_cm_notifiables_on_notification_type"
  end

  create_table "cm_page_builder_rails_page_components", force: :cascade do |t|
    t.string "uuid", null: false
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
    t.index ["ar_model_name", "action_name", "cm_role_id"], name: "index_cm_permissions_on_model_action_role", unique: true
    t.index ["cm_role_id"], name: "index_cm_permissions_on_cm_role_id"
  end

  create_table "cm_platform_settings", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.bigint "category_id"
    t.text "description"
    t.text "value"
    t.string "created_by_type"
    t.bigint "created_by_id"
    t.string "updated_by_type"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_cm_platform_settings_on_category_id"
    t.index ["created_by_type", "created_by_id"], name: "index_cm_platform_settings_on_created_by"
    t.index ["slug"], name: "index_cm_platform_settings_on_slug"
    t.index ["updated_by_type", "updated_by_id"], name: "index_cm_platform_settings_on_updated_by"
  end

  create_table "cm_prompts", force: :cascade do |t|
    t.string "name", null: false
    t.citext "slug", null: false
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_cm_prompts_on_created_by_id"
    t.index ["name"], name: "index_cm_prompts_on_name", unique: true
    t.index ["slug"], name: "index_cm_prompts_on_slug", unique: true
    t.index ["updated_by_id"], name: "index_cm_prompts_on_updated_by_id"
  end

  create_table "cm_roles", force: :cascade do |t|
    t.string "name"
    t.string "default_redirect_path", default: "/cm_admin/users"
    t.string "string", default: "/cm_admin/users"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cm_support_ticket_employees", force: :cascade do |t|
    t.bigint "cm_support_ticket_id", null: false
    t.integer "employee_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cm_support_ticket_id"], name: "index_cm_support_ticket_employees_on_cm_support_ticket_id"
  end

  create_table "cm_support_tickets", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "created_by_id"
    t.string "created_by_name"
    t.citext "created_by_email"
    t.string "cm_admin_version"
    t.string "browser_name"
    t.string "browser_version"
    t.integer "cm_bridge_ticket_id"
    t.integer "platform_ticket_id"
    t.integer "cm_admin_installation_id"
    t.integer "platform_status", default: 0
    t.integer "bridge_status", default: 0
    t.integer "priority", default: 0
    t.bigint "updated_by_id"
    t.string "updated_by_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_cm_support_tickets_on_created_by_id"
    t.index ["updated_by_id"], name: "index_cm_support_tickets_on_updated_by_id"
  end

  create_table "cm_user_mentions", force: :cascade do |t|
    t.string "mentioned_type"
    t.bigint "mentioned_id"
    t.string "mentionable_type"
    t.bigint "mentionable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mentionable_type", "mentionable_id"], name: "index_cm_user_mentions_on_mentionable"
    t.index ["mentioned_type", "mentioned_id"], name: "index_cm_user_mentions_on_mentioned"
  end

  create_table "cm_webhook_events", force: :cascade do |t|
    t.integer "cm_service"
    t.integer "host_service"
    t.string "event_type", null: false
    t.integer "status", default: 0, null: false
    t.string "event_id"
    t.string "uuid", null: false
    t.text "error_message"
    t.datetime "processed_at"
    t.string "eventable_type"
    t.bigint "eventable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cm_service", "event_id", "event_type"], name: "idx_on_cm_service_event_id_event_type_a39dc27451"
    t.index ["cm_service"], name: "index_cm_webhook_events_on_cm_service"
    t.index ["created_at"], name: "index_cm_webhook_events_on_created_at"
    t.index ["event_id"], name: "index_cm_webhook_events_on_event_id"
    t.index ["event_type"], name: "index_cm_webhook_events_on_event_type"
    t.index ["eventable_type", "eventable_id"], name: "index_cm_webhook_events_on_eventable"
    t.index ["host_service", "event_id", "event_type"], name: "idx_on_host_service_event_id_event_type_5ad8fb1d14"
    t.index ["host_service"], name: "index_cm_webhook_events_on_host_service"
    t.index ["status"], name: "index_cm_webhook_events_on_status"
    t.index ["uuid"], name: "index_cm_webhook_events_on_uuid", unique: true
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

  create_table "consultation_kannada_summaries", force: :cascade do |t|
    t.bigint "consultation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["consultation_id"], name: "index_consultation_kannada_summaries_on_consultation_id"
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
    t.index ["consultation_response_id", "user_id"], name: "consultation_response_id_and_user_id_index", unique: true
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
    t.jsonb "voice_responses", default: {}
    t.string "response_language"
    t.integer "transcription_status", default: 0, null: false
    t.jsonb "transcription_errors", default: [], null: false
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
    t.integer "question_flow", default: 0
    t.bigint "theme_id"
    t.string "title_kannada"
    t.datetime "response_deadline"
    t.datetime "feedback_submitted_at"
    t.datetime "acknowledged_at"
    t.datetime "policy_released_at"
    t.index ["deleted_at"], name: "index_consultations_on_deleted_at"
    t.index ["department_id"], name: "index_consultations_on_department_id"
    t.index ["feedback_email_message_id"], name: "index_consultations_on_feedback_email_message_id"
    t.index ["theme_id"], name: "index_consultations_on_theme_id"
  end

  create_table "ct_file_exports", force: :cascade do |t|
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

  create_table "ct_file_imports", force: :cascade do |t|
    t.string "action_name"
    t.bigint "added_by_id", null: false
    t.string "added_by_type", null: false
    t.bigint "associated_model_id"
    t.string "associated_model_name"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.jsonb "error_report", default: {}
    t.integer "import_type"
    t.string "importer_class_name"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["added_by_type", "added_by_id"], name: "index_file_imports_on_added_by"
  end

  create_table "ct_page_views", force: :cascade do |t|
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.citext "name", null: false
    t.string "ar_model_name", null: false
    t.string "associated_ar_model_name", default: "", null: false
    t.string "visible_columns", default: [], array: true
    t.string "hidden_columns", default: [], array: true
    t.boolean "is_default", default: false, null: false
    t.integer "view_type", default: 0
    t.integer "records_per_page", default: 20
    t.jsonb "filter_params", default: {}
    t.json "sort_params", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ar_model_name"], name: "index_ct_page_views_on_ar_model_name"
    t.index ["associated_ar_model_name"], name: "index_ct_page_views_on_associated_ar_model_name"
    t.index ["owner_type", "owner_id", "ar_model_name", "associated_ar_model_name"], name: "index_ct_page_views_on_unique_default", unique: true, where: "(is_default = true)"
    t.index ["owner_type", "owner_id"], name: "index_ct_page_views_on_owner"
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
    t.string "name_kannada"
    t.index ["deleted_at"], name: "index_departments_on_deleted_at"
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

  create_table "positions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.integer "selected_options_limit"
    t.boolean "has_choice_priority", default: false
    t.boolean "accept_voice_message", default: false
    t.text "question_text_kannada"
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

  create_table "response_option_breakdowns", force: :cascade do |t|
    t.bigint "response_question_summary_id", null: false
    t.integer "option_id", null: false
    t.string "option_text", null: false
    t.integer "selection_count", default: 0, null: false
    t.float "percentage", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["response_question_summary_id"], name: "idx_on_response_question_summary_id_f5a4ef0ddb"
  end

  create_table "response_question_summaries", force: :cascade do |t|
    t.bigint "response_summary_id", null: false
    t.integer "question_id", null: false
    t.string "question_text", null: false
    t.string "question_type", null: false
    t.boolean "is_optional", default: false, null: false
    t.integer "position"
    t.integer "total_responses", default: 0, null: false
    t.integer "text_response_count"
    t.integer "voice_response_count"
    t.integer "other_option_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["response_summary_id"], name: "index_response_question_summaries_on_response_summary_id"
  end

  create_table "response_rounds", force: :cascade do |t|
    t.bigint "consultation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "round_number"
    t.index ["consultation_id"], name: "index_response_rounds_on_consultation_id"
  end

  create_table "response_summaries", force: :cascade do |t|
    t.bigint "consultation_id", null: false
    t.integer "total_responses", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["consultation_id"], name: "index_response_summaries_on_consultation_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "showcase_slides", force: :cascade do |t|
    t.string "title", null: false
    t.string "cta_url"
    t.string "video_url"
    t.string "cta_label"
    t.integer "status", default: 0, null: false
    t.integer "position"
    t.datetime "published_at"
    t.datetime "archived_at"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_showcase_slides_on_created_by_id"
    t.index ["updated_by_id"], name: "index_showcase_slides_on_updated_by_id"
  end

  create_table "team_members", force: :cascade do |t|
    t.string "name"
    t.string "designation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "linkedin_url"
    t.integer "member_type", default: 0, null: false
    t.integer "status", default: 1, null: false
    t.index ["member_type"], name: "index_team_members_on_member_type"
    t.index ["status"], name: "index_team_members_on_status"
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

  create_table "user_preferences", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "preferable_type", null: false
    t.bigint "preferable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["preferable_type", "preferable_id"], name: "index_user_preferences_on_preferable"
    t.index ["user_id", "preferable_type", "preferable_id"], name: "index_user_preferences_on_user_and_preferable", unique: true
    t.index ["user_id"], name: "index_user_preferences_on_user_id"
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
    t.jsonb "notification_settings", default: {"newsletter_subscription" => true, "notify_for_new_consultation" => true}
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
    t.integer "referring_consultation_id"
    t.bigint "cm_role_id"
    t.string "current_ip"
    t.string "sign_up_ip"
    t.datetime "last_active_at"
    t.string "locale", default: "en"
    t.integer "status", default: 0, null: false
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
    t.string "action_type"
    t.string "action_name"
    t.index ["action_name"], name: "index_versions_on_action_name"
    t.index ["action_type"], name: "index_versions_on_action_type"
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
  add_foreign_key "api_tokens", "users"
  add_foreign_key "case_studies", "themes"
  add_foreign_key "clause_feedbacks", "clauses"
  add_foreign_key "clause_feedbacks", "consultation_responses"
  add_foreign_key "clauses", "constants", column: "clause_type_id"
  add_foreign_key "clauses", "consultations"
  add_foreign_key "cm_cron_job_logs", "cm_cron_jobs", column: "cron_job_id"
  add_foreign_key "cm_email_logs", "users", column: "triggered_by_id"
  add_foreign_key "cm_geo_ip_networks", "cm_geo_ip_locations"
  add_foreign_key "cm_page_builder_rails_page_components", "cm_page_builder_rails_pages", column: "page_id"
  add_foreign_key "cm_permissions", "cm_roles"
  add_foreign_key "cm_platform_settings", "constants", column: "category_id"
  add_foreign_key "cm_prompts", "users", column: "created_by_id"
  add_foreign_key "cm_prompts", "users", column: "updated_by_id"
  add_foreign_key "cm_support_ticket_employees", "cm_support_tickets"
  add_foreign_key "cm_support_tickets", "users", column: "created_by_id"
  add_foreign_key "cm_support_tickets", "users", column: "updated_by_id"
  add_foreign_key "constant_maps", "constants"
  add_foreign_key "consultation_hindi_summaries", "consultations"
  add_foreign_key "consultation_kannada_summaries", "consultations"
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
  add_foreign_key "response_option_breakdowns", "response_question_summaries"
  add_foreign_key "response_question_summaries", "response_summaries"
  add_foreign_key "response_rounds", "consultations"
  add_foreign_key "response_summaries", "consultations"
  add_foreign_key "showcase_slides", "users", column: "created_by_id"
  add_foreign_key "showcase_slides", "users", column: "updated_by_id"
  add_foreign_key "user_preferences", "users"
  add_foreign_key "users", "cm_roles"
  add_foreign_key "users", "organisations"
end
