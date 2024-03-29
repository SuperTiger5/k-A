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

ActiveRecord::Schema.define(version: 20200919155909) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "started_at_temporary"
    t.datetime "finished_at"
    t.datetime "finished_at_temporary"
    t.string "note"
    t.string "note_temporary"
    t.string "work_details"
    t.string "work_details_temporary"
    t.integer "user_id"
    t.string "overtime_request"
    t.string "overtime_status"
    t.string "overtime_result"
    t.string "overtime_result_temporary"
    t.string "overtime_check", default: "申請中"
    t.string "one_month_check", default: "申請中"
    t.string "overtime_change"
    t.string "one_month_change"
    t.string "next_day"
    t.string "next_day_one_month"
    t.string "overtime_superior_confirmation"
    t.string "one_month_superior_confirmation"
    t.string "one_month_request"
    t.string "one_month_status"
    t.datetime "scheduled_end_time"
    t.datetime "scheduled_end_time_temporary"
    t.string "one_month_approval_changed"
    t.datetime "before_started_at"
    t.datetime "before_finished_at"
    t.date "one_month_approval_day"
    t.string "next_overtime_or_one_month"
    t.string "overtime_superior_id"
    t.string "one_month_superior_id"
    t.string "superior_one_month"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "final_one_month_request"
    t.string "final_one_month_approval"
    t.string "final_one_month_superior_confirmation"
    t.string "final_one_month_check", default: "申請中"
    t.string "final_one_month_change"
    t.string "final_one_month_status", default: "所属長承認　未"
    t.datetime "request_final_one_month"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "places", force: :cascade do |t|
    t.string "name"
    t.string "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type_of_place"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "affiliation"
    t.boolean "superior", default: false
    t.string "uid"
    t.datetime "basic_work_time", default: "2020-10-09 23:00:00"
    t.string "employee_number"
    t.datetime "designated_work_start_time", default: "2020-10-10 00:00:00"
    t.datetime "designated_work_end_time", default: "2020-10-10 09:00:00"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
