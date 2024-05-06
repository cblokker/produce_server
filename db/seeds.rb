# NOTE: This seed file depends on the service objects working as intended. Any change to
#       to service objects can affect this file. This is just for example only, of how to use the
#       service objects to build upon, which could ultimately be used for bigger use-cases tied to
#       API endpoints connected to a frontend.

def seed_users
  User.upsert_all(
    [
      {
        id: 1,
        name: 'Buyer 1',
        role: :buyer
      },
      {
        id: 2,
        name: 'Buyer 2',
        role: :buyer
      },
      {
        id: 3,
        name: 'Buyer 3',
        role: :buyer
      },
      {
        id: 4,
        name: 'Seller 1',
        role: :seller
      },
      {
        id: 5,
        name: 'Seller 2',
        role: :seller
      },
      {
        id: 6,
        name: 'Seller 3',
        role: :seller
      }
    ],
    unique_by: :id
  )
end

def seed_produce
  Produce.upsert_all(
    [
      {
        name: 'banana'
      },
      {
        name: 'orange'
      },
      {
        name: 'apple'
      },
      {
        name: 'potato'
      },
      {
        name: 'tomato'
      },
      {
        name: 'salmon'
      },
      {
        name: 'habanero'
      },
      {
        name: 'olive'
      },
      {
        name: 'cilantro'
      },
      {
        name: 'cherry'
      }
    ],
    unique_by: :name
  )
end

def seed_inventory_for_sellers
  sellers = User.where(role: :seller).includes(:inventory_items)
  produce_ids = Produce.pluck(:id)
  possible_prices = [0.29, 1.43, 0.49, 0.99]

  # V2: Can create service to add inventory for sellers when getting scanned in.
  #     Also think about shelf-life of produce & how that ties to inventory renewal/refreshment.
  sellers.each do |seller|  
    next if seller.has_inventory?

    num_items_to_create = rand(10)
    sampled_produce_ids = produce_ids.sample(num_items_to_create)
    inventory_items = num_items_to_create.times.map do
      {
        seller_id: seller.id,
        produce_id: sampled_produce_ids.pop, # Use pop to ensure uniqueness
        unit_price: possible_prices.sample,
        quantity: rand(10_000..20_000)
      }
    end

    InventoryItem.insert_all(inventory_items)
  end
end

def seed_order_purchases
  buyers = User.where(role: :buyer)
  inventory_item_ids = InventoryItem.pluck(:id)

  20.times do
    buyer = buyers.sample
    random_inventory_item_ids = inventory_item_ids.sample(rand(3..9))

    inventory_items_with_quantities = random_inventory_item_ids.map do |id|
      {
        inventory_item_id: id,
        quantity: rand(1..10)
      }
    end

    # TODO: Handle StandardError: Insufficient quantity for banana
    OrderService::PurchaseOrder.new(
      buyer_id: buyer.id,
      inventory_items_with_quantities: inventory_items_with_quantities
    ).call
  end
end

def seed_cancelled_orders
  return nil if Order.where(status: :cancelled).count > 0 # to make idempotent

  random_orders = Order.order('RANDOM()').first(5) 

  # V2: Could create a service that bulk cancels orders & place it in a sidekiq job
  random_orders.each do |order|
    OrderService::CancelOrder.new(order: order).call
  end
end

seed_users
seed_produce
seed_inventory_for_sellers
seed_order_purchases
seed_cancelled_orders
