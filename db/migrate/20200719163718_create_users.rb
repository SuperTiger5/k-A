class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
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
      t.datetime "basic_work_time", default: "2020-10-10 08:00:00".in_time_zone
      t.string "employee_number"
      t.datetime "designated_work_start_time", default: "2020-10-10 09:00:00".in_time_zone
      t.datetime "designated_work_end_time", default: "2020-10-10 18:00:00".in_time_zone
      t.index ["email"], name: "index_users_on_email", unique: true
      t.timestamps
      
      
    end
  end
end
