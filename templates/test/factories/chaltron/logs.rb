FactoryBot.define do
  factory :chaltron_log, class: 'Chaltron::Log' do
    message { Faker::Hipster.paragraph }
    severity { Chaltron::Log::SEVERITIES.sample }
    category { %w[login user_admin].sample }
  end
end
