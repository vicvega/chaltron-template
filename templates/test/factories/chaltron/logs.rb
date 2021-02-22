FactoryBot.define do
  factory :chaltron_log, class: 'Chaltron::Log' do
    message { FFaker::HipsterIpsum.paragraph }
    severity { Chaltron::Log::SEVERITIES.sample }
    category { FFaker::Company.bs }
  end
end
