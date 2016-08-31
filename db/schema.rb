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

ActiveRecord::Schema.define(version: 20160831085539) do

  create_table "authie_sessions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "token"
    t.string   "browser_id"
    t.integer  "user_id"
    t.boolean  "active",                           default: true
    t.text     "data",               limit: 65535
    t.datetime "expires_at"
    t.datetime "login_at"
    t.string   "login_ip"
    t.datetime "last_activity_at"
    t.string   "last_activity_ip"
    t.string   "last_activity_path"
    t.string   "user_agent"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_type"
    t.integer  "parent_id"
    t.datetime "two_factored_at"
    t.string   "two_factored_ip"
    t.integer  "requests",                         default: 0
    t.datetime "password_seen_at"
    t.index ["browser_id"], name: "index_authie_sessions_on_browser_id", using: :btree
    t.index ["token"], name: "index_authie_sessions_on_token", using: :btree
    t.index ["user_id"], name: "index_authie_sessions_on_user_id", using: :btree
  end

  create_table "certificate_authorities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.text     "private_key",         limit: 65535
    t.text     "certificate",         limit: 65535
    t.datetime "expires_at"
    t.string   "country"
    t.string   "state"
    t.string   "locality"
    t.string   "organization"
    t.string   "organizational_unit"
    t.string   "common_name"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "certificates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "certificate_authority_id"
    t.integer  "serial"
    t.string   "country"
    t.string   "state"
    t.string   "locality"
    t.string   "organization"
    t.string   "organizational_unit"
    t.string   "common_name"
    t.datetime "expires_at"
    t.text     "certificate",              limit: 65535
    t.text     "csr",                      limit: 65535
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.datetime "revoked_at"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "username"
    t.string   "password_digest"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "email_address"
    t.string   "invite_token"
  end

end
