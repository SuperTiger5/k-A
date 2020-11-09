class AddUserToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :designated_work_start_time, :datetime, default: "2020-10-10 09:00:00".in_time_zone
    add_column :users, :designated_work_end_time, :datetime, default: "2020-10-10 18:00:00".in_time_zone
  end
end
