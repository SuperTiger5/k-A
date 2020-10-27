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
             
User.create!(name: "サンプル",
             email: "sample@email.com",
             uid: "4",
             employee_number: 4,
             password: "password",
             password_confirmation: "password")
             
Place.create!(name: "東京",
              type_of_place: "出勤",
              number: 1)
              
Place.create!(name: "大阪",
              type_of_place: "退勤",
              number: 2)              
p "Seed作成完了"