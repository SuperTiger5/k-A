class AddUserToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :designated_work_start_time, :datetime, default: "2020-10-10 00:00:00"
    add_column :users, :designated_work_end_time, :datetime, default: "2020-10-10 09:00:00"
  end
end
