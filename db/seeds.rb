User.create!(name: "管理者",
             email: "admin@email.com",
             admin: true,
             superior: false,
             uid: "1",
             employee_number: 1,
             password: "password",
             password_confirmation: "password")

User.create!(name: "上長１",
             email: "superior1@email.com",
             admin: false,
             superior: true,
             uid: "2",
             employee_number: 2,
             password: "password",
             password_confirmation: "password")
             
User.create!(name: "上長2",
             email: "superior2@email.com",
             admin: false,
             superior: true,
             uid: "3",
             employee_number: 3,
             password: "password",
             password_confirmation: "password")             
p "Seed作成完了"