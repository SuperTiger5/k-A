class RemoveRrrFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :designated_work_start_time, :time
    remove_column :users, :designated_work_end_time, :time
  end
end
