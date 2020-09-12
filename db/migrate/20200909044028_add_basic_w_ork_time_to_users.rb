class AddBasicWOrkTimeToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :basic_work_times, :datetime, default: "08-00"
  end
end
