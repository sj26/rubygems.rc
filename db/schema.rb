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

ActiveRecord::Schema.define(:version => 20121117025753) do

  create_table "versions", :force => true do |t|
    t.string   "version"
    t.string   "platform"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.text     "summary"
    t.text     "description"
    t.string   "name",                                            :null => false
    t.boolean  "prerelease",                   :default => false, :null => false
    t.string   "version_order", :limit => nil
    t.string   "full_name",                                       :null => false
    t.boolean  "latest",                       :default => false, :null => false
  end

  add_index "versions", ["full_name"], :name => "index_versions_on_full_name"
  add_index "versions", ["name", "version_order", "platform"], :name => "index_versions_on_name_and_version_order_and_platform", :unique => true

end
