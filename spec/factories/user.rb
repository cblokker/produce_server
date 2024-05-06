FactoryBot.define do
  factory :user do
    name { Faker::Company.unique.name }
  end
end
