FactoryBot.define do
  factory :user do
    username { FFaker::Internet.user_name }
    fullname { FFaker::Name.name_with_prefix }
    email { FFaker::Internet.email }
    password { 'SuperS3cr3t!' }
    password_confirmation { password }
  end
end
