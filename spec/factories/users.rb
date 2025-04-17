FactoryBot.define do 
  factory :user do 
    name { Faker::Name.name[0, 10] }
    email { Faker::Internet.email }
    password { 'secure123' }
    password_confirmation { 'secure123' }
  end
end