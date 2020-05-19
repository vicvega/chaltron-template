FactoryBot.define do
  factory :log do
    message { FFaker::HipsterIpsum.paragraph }
    severity { Log::SEVERITIES.sample }
    category { FFaker::Company.bs }
  end
end
