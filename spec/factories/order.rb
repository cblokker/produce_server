FactoryBot.define do
  factory :order do
    association :buyer, factory: :user
    total_price { 49.95 }
    status { :pending }
  end
end
