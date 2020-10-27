class CreateAttendances < ActiveRecord::Migration[5.1]
  def change
    create_table :attendances do |t|
      t.date :worked_on
      t.datetime :started_at
      t.datetime :finished_at
      t.string :note
      t.string :work_details
      t.references :user, foreign_key: true
      t.string :overtime_request
      t.string :overtime_status
      t.string :overtime_check
      t.string :overtime_approval
      t.string :overtime_change
      t.string :next_day
      t.string :overtime_superior_confirmation
      t.datetime :scheduled_end_time
      t.timestamps
    end
  end
end
