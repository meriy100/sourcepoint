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

ActiveRecord::Schema.define(version: 20170913075759) do

  create_table "assignments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "code",                          default: "",    null: false
    t.string   "name",                          default: "",    null: false
    t.datetime "opening_time",                                  null: false
    t.datetime "preferred_deadline",                            null: false
    t.datetime "final_deadline",                                null: false
    t.integer  "files",                         default: 1,     null: false
    t.boolean  "utf_8",                         default: true,  null: false
    t.integer  "warnings_allowed",              default: 0,     null: false
    t.integer  "max_file_size",                 default: 10000, null: false
    t.boolean  "compile",                       default: true,  null: false
    t.string   "compiler_options",              default: "",    null: false
    t.float    "grade_contribution", limit: 24, default: 1.0,   null: false
    t.integer  "course_id",                                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attempts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.datetime "submitted",                                                 null: false
    t.binary   "file1",                 limit: 65535
    t.binary   "messages",              limit: 65535
    t.string   "status",                              default: "unchecked", null: false
    t.float    "mark",                  limit: 24
    t.text     "comment",               limit: 65535
    t.integer  "assignment_id",                                             null: false
    t.integer  "user_id",                                                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "encode_code",           limit: 65535
    t.integer  "current_assignment_id"
    t.index ["assignment_id"], name: "index_attempts_on_assignment_id", using: :btree
    t.index ["current_assignment_id"], name: "index_attempts_on_current_assignment_id", using: :btree
    t.index ["user_id"], name: "index_attempts_on_user_id", using: :btree
  end

  create_table "checks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.boolean "valiable_order",               default: false, null: false
    t.boolean "blacket",                      default: false, null: false
    t.boolean "success",                      default: false, null: false
    t.boolean "near",                         default: false, null: false
    t.boolean "complete",                     default: false, null: false
    t.text    "remarks",        limit: 65535
  end

  create_table "courses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "name",                                             null: false
    t.text     "description",         limit: 65535,                null: false
    t.datetime "enrollment_deadline"
    t.boolean  "visible",                           default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "enrollments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "course_id",               null: false
    t.integer  "user_id",                 null: false
    t.string   "seat",       default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["course_id", "user_id"], name: "index_courses_users_on_course_id_and_user_id", unique: true, using: :btree
  end

  create_table "lines", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "attempt_id",                    null: false
    t.integer  "submission_id",                 null: false
    t.integer  "number",                        null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.boolean  "deleted_line",  default: false
    t.index ["attempt_id", "submission_id"], name: "index_lines_on_attempt_id_and_submission_id", using: :btree
  end

  create_table "submissions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "submitted",                                         null: false
    t.binary   "file1",         limit: 65535
    t.binary   "messages",      limit: 65535
    t.string   "status",                      default: "unchecked", null: false
    t.float    "mark",          limit: 24
    t.text     "comment",       limit: 65535
    t.integer  "assignment_id",                                     null: false
    t.integer  "user_id",                                           null: false
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "check_id"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "login",                     limit: 40
    t.string   "email",                     limit: 100
    t.string   "crypted_password",          limit: 40
    t.string   "salt",                      limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            limit: 40
    t.datetime "remember_token_expires_at"
    t.string   "family_name",               limit: 60,  default: ""
    t.string   "given_name",                limit: 60,  default: ""
    t.string   "role",                      limit: 20,  default: "student"
    t.index ["login"], name: "index_users_on_login", unique: true, using: :btree
  end

end
