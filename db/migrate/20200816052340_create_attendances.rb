class CreateAttendances < ActiveRecord::Migration[5.1]
  def change
    create_table :attendances do |t|
      t.date :worked_on
      t.datetime :started_at
      t.datetime :started_at_temporary
      t.datetime :finished_at
      t.datetime :finished_at_temporary
      t.string :note
      t.string :note_temporary
      t.string :work_details
      t.string :work_details_temporary
      t.references :user, foreign_key: true
      t.string :overtime_request
      t.string :overtime_status
      t.string :overtime_check, default: "申請中"
      t.string :one_month_check, default: "申請中"
      t.string :overtime_approval
      t.string :overtime_change
      t.string :one_month_change
      t.string :next_day
      t.string :next_day_one_month
      t.string :overtime_superior_confirmation
      t.string :one_month_superior_confirmation
      t.string :edit_one_month_request
      t.string :edit_one_month_approval
      t.string :one_month_status
      t.datetime :scheduled_end_time
      t.datetime :scheduled_end_time_temporary
      t.timestamps
    end
  end
end
