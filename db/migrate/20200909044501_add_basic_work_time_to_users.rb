class AddBasicWorkTimeToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :basic_work_time, :datetime, default: "2020-09-09 23:00:00"
  end
end
