FactoryBot.define do
  factory :chaltron_log, class: 'Chaltron::Log' do
    message { FFaker::HipsterIpsum.paragraph }
    severity { Chaltron::Log::SEVERITIES.sample }
    category { %w[login user_admin].sample }
  end
end
