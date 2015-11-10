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

ActiveRecord::Schema.define(version: 20151109214132) do

  create_table "brands", force: :cascade do |t|
    t.string   "name"
    t.string   "code"
    t.string   "alternative"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "devices", force: :cascade do |t|
    t.string   "name"
    t.string   "serial"
    t.string   "asset_id"
    t.string   "alternative"
    t.integer  "model_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "devices", ["model_id"], name: "index_devices_on_model_id"

  create_table "devices_groups", force: :cascade do |t|
    t.integer "device_id"
    t.integer "group_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.string   "value"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "models", force: :cascade do |t|
    t.string   "name"
    t.string   "code"
    t.string   "alternative"
    t.integer  "brand_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "models", ["brand_id"], name: "index_models_on_brand_id"

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "provider"
    t.string "uid"
  end

end
