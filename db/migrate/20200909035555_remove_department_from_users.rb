class RemoveDepartmentFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :department, :string
  end
end
