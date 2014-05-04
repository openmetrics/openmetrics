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

ActiveRecord::Schema.define(version: 20140504003834) do

  create_table "ip_lookups", force: true do |t|
    t.string   "target"
    t.text     "scanresult"
    t.string   "job_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "running_services", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "system_id"
    t.integer  "service_id"
    t.text     "description"
  end

  create_table "services", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

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

  add_index "sidekiq_jobs", ["class_name"], name: "index_sidekiq_jobs_on_class_name"
  add_index "sidekiq_jobs", ["enqueued_at"], name: "index_sidekiq_jobs_on_enqueued_at"
  add_index "sidekiq_jobs", ["finished_at"], name: "index_sidekiq_jobs_on_finished_at"
  add_index "sidekiq_jobs", ["jid"], name: "index_sidekiq_jobs_on_jid"
  add_index "sidekiq_jobs", ["queue"], name: "index_sidekiq_jobs_on_queue"
  add_index "sidekiq_jobs", ["retry"], name: "index_sidekiq_jobs_on_retry"
  add_index "sidekiq_jobs", ["started_at"], name: "index_sidekiq_jobs_on_started_at"
  add_index "sidekiq_jobs", ["status"], name: "index_sidekiq_jobs_on_status"

  create_table "systems", force: true do |t|
    t.string   "name"
    t.string   "fqdn"
    t.string   "operating_system"
    t.string   "operating_system_flavour"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "test_execution_results", force: true do |t|
    t.integer  "test_execution_id"
    t.text     "result"
    t.integer  "duration"
    t.text     "output"
    t.integer  "exitstatus"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "test_executions", force: true do |t|
    t.integer  "test_plan_id"
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "job_id"
  end

  create_table "test_item_types", force: true do |t|
    t.string   "model_name",  null: false
    t.string   "name",        null: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "test_item_types", ["model_name"], name: "index_test_item_types_on_model_name", unique: true

  create_table "test_items", force: true do |t|
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "description"
    t.string   "format"
    t.text     "markup"
  end

  create_table "test_plans", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["username"], name: "index_users_on_username", unique: true

  create_table "webtests", force: true do |t|
    t.text     "description"
    t.string   "base_url"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
