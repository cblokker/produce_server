FactoryBot.define do
  factory :order_detail do
    unit_price { "9.99" }
    quantity { 5 }
    association :order
    association :inventory_item
  end
end
