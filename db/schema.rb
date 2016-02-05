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

ActiveRecord::Schema.define(version: 20160205011121) do

  create_table "attempts", force: :cascade do |t|
    t.datetime "date"
    t.integer  "completion"
    t.integer  "climb_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "attempts", ["climb_id"], name: "index_attempts_on_climb_id"

  create_table "climbs", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "grade"
    t.boolean  "success"
    t.string   "location"
    t.string   "name"
    t.integer  "length"
    t.string   "length_unit"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "climbs", ["user_id"], name: "index_climbs_on_user_id"

  create_table "events", force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "label"
    t.integer  "user_id"
    t.string   "type"
    t.integer  "perception"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "events", ["user_id"], name: "index_events_on_user_id"

  create_table "mesocycles", force: :cascade do |t|
    t.integer  "event_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "label"
    t.integer  "reference_id"
    t.string   "type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "mesocycles", ["event_id"], name: "index_mesocycles_on_event_id"

  create_table "microcycles", force: :cascade do |t|
    t.integer  "mesocycle_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "label"
    t.integer  "reference_id"
    t.string   "type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "microcycles", ["mesocycle_id"], name: "index_microcycles_on_mesocycle_id"

  create_table "users", force: :cascade do |t|
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
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.date     "birthdate"
    t.string   "gender"
    t.integer  "weight"
    t.string   "weight_unit"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "postcode"
    t.boolean  "is_admin"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "workouts", force: :cascade do |t|
    t.integer  "microcycle_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "label"
    t.integer  "reference_id"
    t.string   "type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "workouts", ["microcycle_id"], name: "index_workouts_on_microcycle_id"

end
