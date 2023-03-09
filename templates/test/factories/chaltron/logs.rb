FactoryBot.define do
  factory :chaltron_log, class: "Chaltron::Log" do
    message { Faker::Hipster.paragraph }
    severity { Chaltron::Log.severities.keys.sample }
    category { %w[login user_admin].sample }
  end
end
