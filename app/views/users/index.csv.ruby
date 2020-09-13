require 'csv'

CSV.generate do |csv|
  csv_column_names = %w(name email  affiliation employee_number uid basic_work_time designated_work_start_time designated_work_end_time superior admin password)
  csv << csv_column_names
  @users.pluck(*csv_column_names).each do |user|
    csv << user
  end
end
