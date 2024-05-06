FactoryBot.define do
  factory :order do
    association :buyer, factory: :user
    total_price { 49.95 }
    status { :pending }

    # factory :order_with_details do
    #   transient do
    #     posts_count { 5 }
    #   end

    #   after(:create) do |order, context|
    #     create_list(:order_detail, context.posts_count, order: order)
    #     # You may need to reload the record here, depending on your application
    #     user.reload
    #   end
    # end
  end
end
