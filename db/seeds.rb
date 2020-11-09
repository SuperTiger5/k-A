User.create!(name: "管理者",
             email: "admin@email.com",
             admin: true,
             superior: false,
             uid: "1",
             employee_number: 1,
             password: "password",)

User.create!(name: "上長1",
             email: "superior1@email.com",
             admin: false,
             superior: true,
             uid: "2",
             employee_number: 2,
             password: "password")
             
User.create!(name: "上長2",
             email: "superior2@email.com",
             admin: false,
             superior: true,
             uid: "3",
             employee_number: 3,
             password: "password")
             
User.create!(name: "サンプル1",
             email: "sample@email.com",
             uid: "4",
             employee_number: 4,
             password: "password",
             password_confirmation: "password")
             
15.times do |n|
  name = "name#{n+2}"
  email = "sample#{n+2}@email.com"
  password = "password"
  employee_number = n + 5
  uid = "#{n + 5}"
  User.create!(name: name,
             email: email,
             uid: uid,
             employee_number: employee_number,
             password: password
        )
end
             
Place.create!(name: "東京",
              type_of_place: "出勤",
              number: 1)
              
Place.create!(name: "大阪",
              type_of_place: "退勤",
              number: 2)              
p "Seed作成完了"