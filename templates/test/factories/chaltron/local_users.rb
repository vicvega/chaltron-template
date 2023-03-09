FactoryBot.define do
  factory :chaltron_local_user, class: "Chaltron::LocalUser" do
    username { Faker::Internet.unique.username }
    fullname { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { "SuperS3cr3t!" }
    password_confirmation { password }
  end
end
