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

ActiveRecord::Schema.define(version: 20160208153048) do

<<<<<<< HEAD
  create_table "attempts", force: :cascade do |t|
    t.datetime "date",       default: '2016-02-10 04:13:25'
=======
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attempts", force: :cascade do |t|
    t.datetime "date",       default: '2016-02-10 03:57:50'
>>>>>>> 825f5afb141fd4540ccc52e6566083ed4deb7017
    t.integer  "completion", default: 0
    t.integer  "climb_id"
    t.boolean  "onsight",    default: false
    t.boolean  "flash",      default: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

<<<<<<< HEAD
  add_index "attempts", ["climb_id"], name: "index_attempts_on_climb_id"
=======
  add_index "attempts", ["climb_id"], name: "index_attempts_on_climb_id", using: :btree
>>>>>>> 825f5afb141fd4540ccc52e6566083ed4deb7017

  create_table "climbs", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "climb_type"
    t.integer  "grade"
    t.string   "location"
    t.string   "name"
    t.integer  "length"
    t.string   "length_unit"
    t.boolean  "outdoor",     default: true
    t.boolean  "crimpy",      default: false
    t.boolean  "slopey",      default: false
    t.boolean  "pinchy",      default: false
    t.boolean  "pockety",     default: false
    t.boolean  "powerful",    default: false
    t.boolean  "endurance",   default: false
    t.boolean  "technical",   default: false
    t.text     "notes"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

<<<<<<< HEAD
  add_index "climbs", ["user_id"], name: "index_climbs_on_user_id"

  create_table "events", force: :cascade do |t|
    t.datetime "start_date",      default: '2016-02-10 04:13:25'
    t.datetime "end_date",        default: '2016-02-10 04:13:25'
=======
  add_index "climbs", ["user_id"], name: "index_climbs_on_user_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.datetime "start_date",      default: '2016-02-10 04:14:42'
    t.datetime "end_date",        default: '2016-02-10 04:14:42'
>>>>>>> 825f5afb141fd4540ccc52e6566083ed4deb7017
    t.string   "label"
    t.string   "event_type"
    t.integer  "perception"
    t.text     "notes"
    t.boolean  "completed",       default: false
    t.integer  "parent_event_id"
    t.integer  "user_id"
    t.integer  "workout_id"
    t.integer  "microcycle_id"
    t.integer  "mesocycle_id"
    t.integer  "macrocycle_id"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

<<<<<<< HEAD
  add_index "events", ["macrocycle_id"], name: "index_events_on_macrocycle_id"
  add_index "events", ["mesocycle_id"], name: "index_events_on_mesocycle_id"
  add_index "events", ["microcycle_id"], name: "index_events_on_microcycle_id"
  add_index "events", ["parent_event_id"], name: "index_events_on_parent_event_id"
  add_index "events", ["user_id"], name: "index_events_on_user_id"
  add_index "events", ["workout_id"], name: "index_events_on_workout_id"
=======
  add_index "events", ["macrocycle_id"], name: "index_events_on_macrocycle_id", using: :btree
  add_index "events", ["mesocycle_id"], name: "index_events_on_mesocycle_id", using: :btree
  add_index "events", ["microcycle_id"], name: "index_events_on_microcycle_id", using: :btree
  add_index "events", ["parent_event_id"], name: "index_events_on_parent_event_id", using: :btree
  add_index "events", ["user_id"], name: "index_events_on_user_id", using: :btree
  add_index "events", ["workout_id"], name: "index_events_on_workout_id", using: :btree
>>>>>>> 825f5afb141fd4540ccc52e6566083ed4deb7017

  create_table "macrocycles", force: :cascade do |t|
    t.string   "label"
    t.string   "macrocycle_type"
    t.integer  "user_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

<<<<<<< HEAD
  add_index "macrocycles", ["user_id"], name: "index_macrocycles_on_user_id"
=======
  add_index "macrocycles", ["user_id"], name: "index_macrocycles_on_user_id", using: :btree
>>>>>>> 825f5afb141fd4540ccc52e6566083ed4deb7017

  create_table "macrocycles_mesocycles", id: false, force: :cascade do |t|
    t.integer "macrocycle_id"
    t.integer "mesocycle_id"
  end

<<<<<<< HEAD
  add_index "macrocycles_mesocycles", ["macrocycle_id"], name: "index_macrocycles_mesocycles_on_macrocycle_id"
  add_index "macrocycles_mesocycles", ["mesocycle_id"], name: "index_macrocycles_mesocycles_on_mesocycle_id"
=======
  add_index "macrocycles_mesocycles", ["macrocycle_id"], name: "index_macrocycles_mesocycles_on_macrocycle_id", using: :btree
  add_index "macrocycles_mesocycles", ["mesocycle_id"], name: "index_macrocycles_mesocycles_on_mesocycle_id", using: :btree
>>>>>>> 825f5afb141fd4540ccc52e6566083ed4deb7017

  create_table "mesocycles", force: :cascade do |t|
    t.string   "label"
    t.string   "mesocycle_type"
    t.integer  "user_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

<<<<<<< HEAD
  add_index "mesocycles", ["user_id"], name: "index_mesocycles_on_user_id"
=======
  add_index "mesocycles", ["user_id"], name: "index_mesocycles_on_user_id", using: :btree
>>>>>>> 825f5afb141fd4540ccc52e6566083ed4deb7017

  create_table "mesocycles_microcycles", id: false, force: :cascade do |t|
    t.integer "microcycle_id"
    t.integer "mesocycle_id"
  end

<<<<<<< HEAD
  add_index "mesocycles_microcycles", ["mesocycle_id"], name: "index_mesocycles_microcycles_on_mesocycle_id"
  add_index "mesocycles_microcycles", ["microcycle_id"], name: "index_mesocycles_microcycles_on_microcycle_id"
=======
  add_index "mesocycles_microcycles", ["mesocycle_id"], name: "index_mesocycles_microcycles_on_mesocycle_id", using: :btree
  add_index "mesocycles_microcycles", ["microcycle_id"], name: "index_mesocycles_microcycles_on_microcycle_id", using: :btree
>>>>>>> 825f5afb141fd4540ccc52e6566083ed4deb7017

  create_table "microcycles", force: :cascade do |t|
    t.string   "label"
    t.string   "microcycle_type"
    t.integer  "user_id"
    t.integer  "duration",        default: 604800
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

<<<<<<< HEAD
  add_index "microcycles", ["user_id"], name: "index_microcycles_on_user_id"
=======
  add_index "microcycles", ["user_id"], name: "index_microcycles_on_user_id", using: :btree
>>>>>>> 825f5afb141fd4540ccc52e6566083ed4deb7017

  create_table "microcycles_workouts", id: false, force: :cascade do |t|
    t.integer "workout_id"
    t.integer "microcycle_id"
  end

<<<<<<< HEAD
  add_index "microcycles_workouts", ["microcycle_id"], name: "index_microcycles_workouts_on_microcycle_id"
  add_index "microcycles_workouts", ["workout_id"], name: "index_microcycles_workouts_on_workout_id"
=======
  add_index "microcycles_workouts", ["microcycle_id"], name: "index_microcycles_workouts_on_microcycle_id", using: :btree
  add_index "microcycles_workouts", ["workout_id"], name: "index_microcycles_workouts_on_workout_id", using: :btree
>>>>>>> 825f5afb141fd4540ccc52e6566083ed4deb7017

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

<<<<<<< HEAD
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
=======
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
>>>>>>> 825f5afb141fd4540ccc52e6566083ed4deb7017

  create_table "workouts", force: :cascade do |t|
    t.string   "label"
    t.string   "workout_type"
    t.integer  "user_id"
    t.text     "description"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

<<<<<<< HEAD
  add_index "workouts", ["user_id"], name: "index_workouts_on_user_id"

=======
  add_index "workouts", ["user_id"], name: "index_workouts_on_user_id", using: :btree

  add_foreign_key "attempts", "climbs"
  add_foreign_key "climbs", "users"
  add_foreign_key "events", "macrocycles"
  add_foreign_key "events", "mesocycles"
  add_foreign_key "events", "microcycles"
  add_foreign_key "events", "users"
  add_foreign_key "events", "workouts"
  add_foreign_key "macrocycles", "users"
  add_foreign_key "mesocycles", "users"
  add_foreign_key "microcycles", "users"
  add_foreign_key "workouts", "users"
>>>>>>> 825f5afb141fd4540ccc52e6566083ed4deb7017
end
