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

ActiveRecord::Schema.define(version: 20151207145233) do

  create_table "hive_mind_hive_plugins", force: :cascade do |t|
    t.string   "hostname"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hive_mind_hive_runner_plugin_version_histories", force: :cascade do |t|
    t.integer  "plugin_id"
    t.integer  "runner_plugin_version_id"
    t.datetime "start_timestamp"
    t.datetime "end_timestamp"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "hive_mind_hive_runner_plugin_versions", force: :cascade do |t|
    t.string   "name"
    t.string   "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hive_mind_hive_runner_version_histories", force: :cascade do |t|
    t.integer  "plugin_id"
    t.integer  "runner_version_id"
    t.datetime "start_timestamp"
    t.datetime "end_timestamp"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "hive_mind_hive_runner_versions", force: :cascade do |t|
    t.string   "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
