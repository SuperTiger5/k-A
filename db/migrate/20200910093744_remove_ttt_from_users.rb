class RemoveTttFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :designated_work_start_time, :datetime
    remove_column :users, :designated_work_end_time, :datetime
  end
end
