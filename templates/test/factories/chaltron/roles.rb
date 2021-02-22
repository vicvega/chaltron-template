FactoryBot.define do
  factory :chaltron_role, class: 'Chaltron::Role' do
    sequence(:name) { |n| "#{FFaker::Lorem.word}_#{n}" }
  end
end
