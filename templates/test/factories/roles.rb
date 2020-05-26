FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "#{FFaker::Lorem.word}_#{n}" }
  end
end
