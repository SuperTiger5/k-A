User.create!(name: "管理者",
             email: "admin@email.com",
             admin: true,
             superior: false,
             uid: "1",
             employee_number: 1,
             designated_work_start_time,
             designated_work_end_time,
             password: "password",
             password_confirmation: "password")

User.create!(name: "上長１",
             email: "superior1@email.com",
             admin: false,
             superior: true,
             uid: "2",
             employee_number: 2,
             designated_work_start_time,
             designated_work_end_time,
             password: "password",
             password_confirmation: "password")
             
User.create!(name: "上長２",
             email: "superior2@email.com",
             admin: false,
             superior: true,
             uid: "3",
             employee_number: 3,
             designated_work_start_time,
             designated_work_end_time,
             password: "password",
             password_confirmation: "password")
             
User.create!(name: "一般ユーザー１",
             email: "sample1@email.com",
             admin: false,
             superior: false,
             uid: "4",
             employee_number: 4,
             designated_work_start_time,
             designated_work_end_time,
             password: "password",
             password_confirmation: "password")
             
User.create!(name: "一般ユーザー２",
             email: "sample2@email.com",
             admin: false,
             superior: false,
             uid: "5",
             employee_number: 5,
             designated_work_start_time,
             designated_work_end_time,
             password: "password",
             password_confirmation: "password")


