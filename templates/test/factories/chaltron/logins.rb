FactoryBot.define do
  factory :chaltron_login, class: "Chaltron::Login" do
    user factory: :chaltron_local_user
    sequence(:device_id) { |n| "#{Faker::Alphanumeric.alphanumeric(number: 10)}_#{n}" }
    ip_address { Faker::Internet.ip_v4_address }
    user_agent { Faker::Internet.user_agent }
  end
end
