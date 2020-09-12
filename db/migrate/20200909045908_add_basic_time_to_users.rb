class AddBasicTimeToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :basic_time, :datetime, default: "2020-09-09 09:00:00"
  end
end
