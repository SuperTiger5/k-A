class AddNewInformationToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :affiliation, :string
    add_column :users, :employee_number, :string
    add_column :users, :designated_work_start_time, :time
    add_column :users, :designated_work_end_time, :time
    add_column :users, :superior, :boolean, default: false
  end
end
