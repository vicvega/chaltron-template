FactoryBot.define do
  factory :chaltron_role, class: 'Chaltron::Role' do
    sequence(:name) { Faker::Lorem.unique.word }
  end
end
