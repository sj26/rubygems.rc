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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120617143429) do

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "latest_version_id"
    t.text     "summary"
    t.text     "description"
  end

  create_table "versions", :force => true do |t|
    t.integer  "project_id",                   :null => false
    t.string   "version"
    t.string   "platform"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "version_order", :default => 0, :null => false
    t.text     "summary"
    t.text     "description"
  end

  add_index "versions", ["project_id", "version", "platform"], :name => "index_versions_on_project_id_and_version_and_platform", :unique => true
  add_index "versions", ["project_id", "version_order", "created_at"], :name => "index_versions_on_project_id_and_version_order_and_created_at"

end
