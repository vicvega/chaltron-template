FactoryBot.define do
  factory :chaltron_user, class: 'Chaltron::User' do
    sequence(:username) { Faker::Internet.unique.username }
    fullname { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'SuperS3cr3t!' }
    password_confirmation { password }
  end
end
