FactoryBot.define do
  factory :user do
    name { Faker::Company.unique.name }

    factory :selle_with_inventory_items do
      transient do
        inventory_count { 5 }
      end

      after(:create) do |user, context|
        create_list(:inventory_items, context.inventory_count, user: user)
        user.reload
      end
    end

    factory :buyer_with_orders do
    end
  end
end
