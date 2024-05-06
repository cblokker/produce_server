FactoryBot.define do
  factory :inventory_item do
    association :seller, factory: :user
    association :produce
    unit_price { 9.99 }
    quantity { 10 }
  end
end
