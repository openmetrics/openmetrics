# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140910093146) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: true do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "collect_plugins", force: true do |t|
    t.string "name"
    t.text   "configuration"
  end

  create_table "collectd_plugins", force: true do |t|
    t.string "name"
    t.text   "configuration"
    t.text   "description"
  end

  create_table "friendly_id_slugs", force: true do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "ip_lookup_results", force: true do |t|
    t.integer  "ip_lookup_id"
    t.text     "result"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ip_lookups", force: true do |t|
    t.string   "target"
    t.string   "job_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.integer  "status"
  end

  create_table "metrics", force: true do |t|
    t.string "plugin"
    t.string "ds"
    t.string "name"
    t.string "rrd_file"
  end

  create_table "metrics_systems", force: true do |t|
    t.integer "system_id"
    t.integer "metric_id"
  end

  add_index "metrics_systems", ["metric_id"], name: "index_metrics_systems_on_metric_id", using: :btree
  add_index "metrics_systems", ["system_id"], name: "index_metrics_systems_on_system_id", using: :btree

  create_table "running_collectd_plugins", force: true do |t|
    t.integer "collectd_plugin_id"
    t.integer "running_service_id"
    t.integer "system_id"
  end

  create_table "running_services", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "system_id"
    t.integer  "service_id"
    t.text     "description"
    t.string   "fqdn"
  end

  create_table "services", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.text     "description"
    t.string   "daemon_name"
    t.string   "init_name"
    t.string   "systemd_name"
    t.string   "fqdn"
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "sidekiq_jobs", force: true do |t|
    t.string   "jid"
    t.string   "queue"
    t.string   "class_name"
    t.text     "args"
    t.boolean  "retry"
    t.datetime "enqueued_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string   "status"
    t.string   "name"
    t.text     "result"
  end

  add_index "sidekiq_jobs", ["class_name"], name: "index_sidekiq_jobs_on_class_name", using: :btree
  add_index "sidekiq_jobs", ["enqueued_at"], name: "index_sidekiq_jobs_on_enqueued_at", using: :btree
  add_index "sidekiq_jobs", ["finished_at"], name: "index_sidekiq_jobs_on_finished_at", using: :btree
  add_index "sidekiq_jobs", ["jid"], name: "index_sidekiq_jobs_on_jid", using: :btree
  add_index "sidekiq_jobs", ["queue"], name: "index_sidekiq_jobs_on_queue", using: :btree
  add_index "sidekiq_jobs", ["retry"], name: "index_sidekiq_jobs_on_retry", using: :btree
  add_index "sidekiq_jobs", ["started_at"], name: "index_sidekiq_jobs_on_started_at", using: :btree
  add_index "sidekiq_jobs", ["status"], name: "index_sidekiq_jobs_on_status", using: :btree

  create_table "system_variables", force: true do |t|
    t.string  "name"
    t.string  "value"
    t.integer "system_id"
  end

  create_table "systems", force: true do |t|
    t.string   "name"
    t.string   "fqdn"
    t.string   "operating_system"
    t.string   "operating_system_flavor"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.text     "description"
    t.string   "cidr"
    t.string   "sshuser"
  end

  add_index "systems", ["slug"], name: "index_systems_on_slug", unique: true, using: :btree

  create_table "test_execution_items", force: true do |t|
    t.string   "format"
    t.text     "markup"
    t.integer  "test_execution_id"
    t.integer  "exitstatus"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "test_item_id"
    t.text     "output"
    t.integer  "status"
    t.text     "error"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.text     "executable"
  end

  create_table "test_execution_results", force: true do |t|
    t.integer  "test_execution_id"
    t.text     "result"
    t.decimal  "duration"
    t.integer  "exitstatus"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "test_executions", force: true do |t|
    t.integer  "test_plan_id"
    t.integer  "user_id"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "job_id"
    t.string   "base_url"
    t.datetime "started_at"
    t.datetime "finished_at"
  end

  create_table "test_item_types", force: true do |t|
    t.string   "model_name",  null: false
    t.string   "name",        null: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "test_item_types", ["model_name"], name: "index_test_item_types_on_model_name", unique: true, using: :btree

  create_table "test_items", force: true do |t|
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "description"
    t.string   "format"
    t.text     "markup"
  end

  create_table "test_plan_items", force: true do |t|
    t.integer "test_plan_id"
    t.integer "test_item_id"
    t.integer "position"
  end

  create_table "test_plans", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "base_url"
    t.string   "slug"
  end

  add_index "test_plans", ["slug"], name: "index_test_plans_on_slug", unique: true, using: :btree

  create_table "test_plans_test_items", force: true do |t|
    t.integer "test_plan_id"
    t.integer "test_item_id"
  end

  create_table "test_suites", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "test_suites_test_cases", id: false, force: true do |t|
    t.integer "test_suite_id"
    t.integer "test_case_id"
  end

  create_table "uploads", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uploaded_file_file_name"
    t.string   "uploaded_file_content_type"
    t.integer  "uploaded_file_file_size"
    t.datetime "uploaded_file_updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                             default: "", null: false
    t.string   "encrypted_password",                default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "slug"
    t.string   "api_token",              limit: 40
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "versions", force: true do |t|
    t.integer  "version_number"
    t.string   "versioned_type"
    t.integer  "versioned_id"
    t.integer  "user_id"
    t.text     "description"
    t.text     "object_changes"
    t.datetime "created_at"
  end

  add_index "versions", ["created_at"], name: "index_versions_on_created_at", using: :btree
  add_index "versions", ["user_id"], name: "index_versions_on_user_id", using: :btree
  add_index "versions", ["version_number"], name: "index_versions_on_version_number", using: :btree
  add_index "versions", ["versioned_type", "versioned_id"], name: "index_versions_on_versioned_type_and_versioned_id", using: :btree

  create_table "webtests", force: true do |t|
    t.text     "description"
    t.string   "base_url"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
