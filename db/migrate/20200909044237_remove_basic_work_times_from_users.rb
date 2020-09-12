class RemoveBasicWorkTimesFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :basic_work_times, :datetime
  end
end
