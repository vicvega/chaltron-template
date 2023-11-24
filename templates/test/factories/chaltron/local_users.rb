FactoryBot.define do
  factory :chaltron_local_user, class: "Chaltron::LocalUser" do
    transient do
      with_roles { [] }
    end
    username { Faker::Internet.unique.username }
    fullname { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { "SuperS3cr3t!" }
    password_confirmation { password }

    after(:build) do |user, evaluator|
      unless evaluator.with_roles.empty?
        user.roles << Array.wrap(evaluator.with_roles).map do |role|
          Chaltron::Role.find_or_create_by(name: role)
        end
      end
    end
  end
end
