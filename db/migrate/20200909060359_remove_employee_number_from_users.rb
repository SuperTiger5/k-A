class RemoveEmployeeNumberFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :employee_number, :int
  end
end
