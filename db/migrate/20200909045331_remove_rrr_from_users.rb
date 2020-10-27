class RemoveRrrFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :designated_work_start_time, :datetime, default: "2020-10-10 00:00:00"
    remove_column :users, :designated_work_end_time, :datetime, default: "2020-10-10 09:00:00"
  end
end
