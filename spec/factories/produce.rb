FactoryBot.define do
  factory :produce do
    name { Faker::Food.unique.vegetables }
  end
end
